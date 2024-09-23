//
//  RoutingTabBarController.swift
//  PlatformRouting
//
//  Created by Qiang Huang on 12/1/18.
//  Copyright © 2018 dYdX. All rights reserved.
//

import Differ
import ParticlesKit
import RoutingKit
import UIToolkits
import Utilities

open class RoutingTabBarController: UITabBarController, ParsingProtocol {
    @IBOutlet public var centerButton: UIButton? {
        didSet {
            didSetCenterButton(oldValue: oldValue)
        }
    }

    @objc public dynamic var badging: UrlBadgingInteractor? {
        didSet {
            changeObservation(from: oldValue, to: badging, keyPath: #keyPath(UrlBadgingInteractor.dictionary)) { [weak self] _, _, _, _ in
                if let self = self {
                    self.updateBadging()
                }
            }
        }
    }

    public static var parserOverwrite: Parser?

    override open var parser: Parser {
        return RoutingTabBarController.parserOverwrite ?? super.parser
    }

    public var maps: [TabbarItemInfo]? {
        didSet {
            if maps != oldValue {
                let current = maps ?? [TabbarItemInfo]()
                let old = oldValue ?? [TabbarItemInfo]()
                let diff: Diff = self.diff(current: current, old: old)
                let patches = self.patches(diff: diff, current: current, old: old)
                update(diff: diff, patches: patches)
                updateBadging()
            }
        }
    }

    @IBInspectable var path: String?

    private var actionPath: String?

    var previousController: UIViewController?

    override open func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
    }

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        RoutingHistory.shared.record(destination: self)
        alignCenterButton()
    }
    
    public func alignCenterButton() {
        if let centerButton = centerButton {
            if let barItems = tabBar.items, barItems.count > 0 {
                for i in 0 ..< barItems.count {
                    if isAction(index: i) {
                        barItems[i].isEnabled = false
                    }
                }
            }
            tabBar.addSubview(centerButton)
            let x = tabBar.centerXAnchor.constraint(equalTo: centerButton.centerXAnchor)
            x.priority = .required
            x.isActive = true
            let constraint = tabBar.topAnchor.constraint(equalTo: centerButton.centerYAnchor)
            constraint.constant = -18
            constraint.priority = .required
            constraint.isActive = true

            tabBar.layoutIfNeeded()
        }
    }

    open func didSetCenterButton(oldValue: UIButton?) {
        if centerButton !== oldValue {
            oldValue?.removeTarget()
            centerButton?.addTarget(self, action: #selector(action(_:)))
        }
    }

    open func diff(current: [TabbarItemInfo], old: [TabbarItemInfo]) -> Diff {
        return old.diff(current) { (object1, object2) -> Bool in
            object1.path == object2.path
        }
    }

    open func patches(diff: Diff, current: [TabbarItemInfo], old: [TabbarItemInfo]) -> [Patch<TabbarItemInfo>] {
        return diff.patch(from: old, to: current) { (element1, element2) -> Bool in
            switch (element1, element2) {
            case let (.insert(at1), .insert(at2)):
                return at1 < at2
            case (.insert, .delete):
                return false
            case (.delete, .insert):
                return true
            case let (.delete(at1), .delete(at2)):
                return at1 > at2
            }
        }
    }

    open func update(diff: Diff, patches: [Patch<TabbarItemInfo>]) {
        var viewControllers = self.viewControllers ?? [UIViewController]()
        for change in patches {
            switch change {
            case let .deletion(index):
                viewControllers.remove(at: index)

            case let .insertion(index: index, element: item):
                installViewController(for: item) { viewController in
                    if let viewController = viewController {
                        if index >= viewControllers.count {
                            viewControllers.append(viewController)
                        } else {
                            viewControllers.insert(viewController, at: index)
                        }
                    }
                }
            }
        }
        self.viewControllers = viewControllers
    }

    private func path(info: TabbarItemInfo) -> String? {
        if let router = Router.shared as? MappedUIKitRouter {
            let request = RoutingRequest(path: info.path)
            return router.transform(request: request).path
        } else {
            return nil
        }
    }

    open func installViewController(for info: TabbarItemInfo, completion: @escaping ((UIViewController?) -> Void)) {
        if let path = path(info: info) {
            if isActionTab(item: info) {
                actionPath = path
                let viewController = UIViewController()
                setup(viewController: viewController, info: info)
                completion(viewController)
            } else {
                if let router = (Router.shared as? MappedUIKitRouter) {
                    router.viewController(for: path) { [weak self] viewController in
                        if let viewController = viewController {
                            if let nav = viewController as? NavigableProtocol {
                                let request = RoutingRequest(path: path)
                                nav.navigate(to: request, animated: false, completion: nil)
                            }
                            if UIDevice.current.canSplit && (info.split ?? false) {
                                let splitter = UISplitViewController()
                                splitter.preferredDisplayMode = .allVisible
                                if let nav = UINavigationController.load(storyboard: "Nav", with: viewController), let rightNav = UINavigationController.loadNavigator(storyboard: "Nav") {
                                    splitter.viewControllers = [nav, rightNav]

                                    self?.setup(viewController: splitter, info: info)
                                    completion(splitter)
                                } else {
                                    completion(nil)
                                }
                            } else {
                                var tabViewController: UIViewController = viewController
                                //if !(viewController is UIViewControllerEmbeddingProtocol) {
                                    if let nav = UINavigationController.load(storyboard: "Nav", with: viewController) {
                                        tabViewController = nav
                                    }
                                //}
                                self?.setup(viewController: tabViewController, info: info)
                                completion(tabViewController)
                            }
                        } else {
                            self?.actionPath = path
                            let viewController = UIViewController()
                            self?.setup(viewController: viewController, info: info)
                            completion(viewController)
                        }
                    }
                } else {
                    actionPath = path
                    let viewController = UIViewController()
                    setup(viewController: viewController, info: info)
                    completion(viewController)
                }
            }
        } else {
            completion(nil)
        }
    }

    private func setup(viewController: UIViewController, info: TabbarItemInfo) {
        let tabbarItem = UITabBarItem()
        tabbarItem.title = info.title
        tabbarItem.image = UIImage.named(info.image, bundles: Bundle.particles)
//        if let selected = info.selected {
//            tabbarItem.selectedImage = UIImage.named(selected, bundles: Bundle.particles)
//        }
        viewController.tabBarItem = tabbarItem
    }

    open func updateBadging() {
        if let viewControllers = viewControllers, let maps = maps, viewControllers.count == maps.count {
            for i in 0 ..< maps.count {
                let viewController = viewControllers[i]
                if let tabbarItem = viewController.tabBarItem {
                    let map = maps[i]
                    tabbarItem.badgeValue = badging?.badge(for: map.path)
                }
            }
        }
    }

    private func isAction(index: Int) -> Bool {
        if centerButton !== nil, let maps = maps {
            return (maps.count == 3 && index == 1) || (maps.count == 5 && index == 2)
        } else {
            return false
        }
    }

    private func isActionTab(item: TabbarItemInfo) -> Bool {
        if item.image == nil {
            return true
        } else if let index = maps?.firstIndex(of: item) {
            return isAction(index: index)
        } else {
            return false
        }
    }

    @IBAction func action(_ sender: Any?) {
        if let path = actionPath {
            Router.shared?.navigate(to: RoutingRequest(path: path), animated: true, completion: nil)
        }
    }
}

public struct TabbarItemInfo: Equatable {
    public init(path: String,
                title: String?,
                image: String,
                split: Bool) {
        self.path = path
        self.title = title
        self.image = image
        self.split = split
    }
    
    public var path: String
    public var title: String?
    public var image: String
    public var split: Bool
}

extension RoutingTabBarController: UITabBarControllerDelegate {
    public func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if previousController == viewController {
            var vc: UIViewController? = viewController
            if let navVC = viewController as? UINavigationController {
                vc = navVC.topViewController
            }
            if let vc = vc {
                if vc.isViewLoaded && (vc.view.window != nil) {
                    vc.scrollToTop()
                }
            }
        }

        previousController = viewController

        if let index = viewControllers?.firstIndex(of: viewController) {
            return !isAction(index: index)
        } else {
            return true
        }
    }
}
