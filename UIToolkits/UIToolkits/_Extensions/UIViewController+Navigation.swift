//
//  UIView+Navigation.swift
//  UIToolkits
//
//  Created by John Huang on 10/8/18.
//  Copyright © 2019 dYdX. All rights reserved.
//

import UIKit
import Utilities

extension UIViewController {
    @objc public static func load(storyboard: String?) -> UIViewController? {
        if let storyboardName = storyboard {
            if let bundle = find(storyboard: storyboard, in: Bundle.particles) {
                let storyboard = UIStoryboard(name: storyboardName, bundle: bundle)
                return storyboard.instantiateInitialViewController()
            }
        }
        return nil
    }

    @objc public static func find(storyboard: String?, in bundles: [Bundle]) -> Bundle? {
        if storyboard != nil {
            var found: Bundle?
            for bundle in bundles {
                if bundle.path(forResource: storyboard, ofType: "storyboardc") != nil {
                    found = bundle
                    break
                }
            }
            return found
        }
        return nil
    }

    @objc public static func navigation(with viewController: UIViewController) -> UINavigationController {
        var navigationController = viewController as? UINavigationController
        if navigationController === nil {
            navigationController = UINavigationController.load(storyboard: "Nav", with: viewController)
            navigationController?.modalPresentationStyle = viewController.modalPresentationStyle
            
            if let sheet = navigationController?.sheetPresentationController,
                let source = viewController.sheetPresentationController {
                sheet.detents = source.detents
                sheet.selectedDetentIdentifier = source.selectedDetentIdentifier
                sheet.delegate = source.delegate
                sheet.preferredCornerRadius = source.preferredCornerRadius
                sheet.prefersEdgeAttachedInCompactHeight = source.prefersEdgeAttachedInCompactHeight
                sheet.prefersScrollingExpandsWhenScrolledToEdge = source.prefersScrollingExpandsWhenScrolledToEdge
                sheet.sourceView = source.sourceView
                sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = source.widthFollowsPreferredContentSizeWhenEdgeAttached
                sheet.largestUndimmedDetentIdentifier = source.largestUndimmedDetentIdentifier
                sheet.prefersGrabberVisible = source.prefersGrabberVisible
            }
            
        }
        return navigationController!
    }

    @objc open func topmost() -> UIViewController? {
        var topmost: UIViewController?
        if let halfController = self as? UIViewControllerHalfProtocol {
            topmost = halfController.floatingManager?.halved?.topmost()
        }
        if topmost == nil, let navigationController = self as? UINavigationController {
            if let last = last(of: navigationController.viewControllers) {
                topmost = last.topmost()
            }
        }

        if topmost == nil, let tabbarController = self as? UITabBarController {
            topmost = tabbarController.selectedViewController?.topmost()
        }

        if topmost == nil {
            if UIDevice.current.canSplit, let splitViewController = self as? UISplitViewController {
                var index: Int = splitViewController.viewControllers.count - 1
                while topmost == nil && index >= 0 {
                    let current = splitViewController.viewControllers[index]
                    if let local = current.topmost() {
                        if local !== current || !(current is UINavigationController) {
                            topmost = local
                        }
                    }
                    index -= 1
                }
            }
            if let presentedViewController = self.presentedViewController, !presentedViewController.dismissing() {
                topmost = presentedViewController.topmost()
            }
        }
        return topmost ?? self
    }

    @objc open func last(of viewControllers: [UIViewController]) -> UIViewController? {
        return viewControllers.last { (viewController) -> Bool in
            !viewController.popping()
        }
    }

    @objc open func presenting() -> Bool {
        return isBeingPresented || (navigationController?.isBeingPresented ?? false)
    }

    @objc open func dismissing() -> Bool {
        return isBeingDismissed || (navigationController?.isBeingDismissed ?? false)
    }

    @objc open func pushing() -> Bool {
        return isMovingToParent && (navigationController?.viewControllers.count ?? 0) > 1
    }

    @objc open func popping() -> Bool {
        return isMovingFromParent
    }

    public func parentViewControllerConforming(protocol _protocol: Protocol) -> UIViewController? {
        if conforms(to: _protocol) {
            return self
        } else {
            var found: UIViewController?
            var node: UIViewController? = parentViewController()
            while found == nil && node != nil {
                if node?.conforms(to: _protocol) ?? false {
                    found = node
                } else {
                    node = node?.parentViewController()
                }
            }
            return found
        }
    }

    public func parentViewController() -> UIViewController? {
        return navigationController ?? presentingViewController ?? parent
    }

    func printTransitionStates() {
        Console.shared.log("pushing=\(pushing())")
        Console.shared.log("popping=\(popping())")
        Console.shared.log("presenting=\(presenting())")
        Console.shared.log("dismissing=\(dismissing())")
    }

    public func dismissWhenForegrounding(animated: Bool) {
        AppState.shared.runForegrounding(task: { [weak self] in
            self?.dismiss(animated: animated)
        })
    }

    public func dismissWhenForegrounding(animated: Bool, error: Error?) {
        AppState.shared.runForegrounding(task: { [weak self] in
            self?.dismiss(animated: true, completion: {
                if let error = error {
                    ErrorInfo.shared?.info(title: nil, message: nil, type: .error, error: error)
                }
            })
        })
    }
}
