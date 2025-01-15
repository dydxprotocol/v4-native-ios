//
//  MappedUIKitRouter.swift
//  PlatformRouting
//
//  Created by John Huang on 12/26/18.
//  Copyright © 2019 dYdX. All rights reserved.
//

import DrawerMenu
import PanModal
import RoutingKit
import UIToolkits
import Utilities

public typealias BacktrackRoutingCompletionBlock = (UIViewController?) -> Void

open class MappedUIKitRouter: MappedRouter {
    let fadeTransitioner = CustomTransition.fade.transitionDelegate

    var actions: [NSObject & NavigableProtocol] = [NSObject & NavigableProtocol]()
    override open func backtrack(request: RoutingRequest, animated: Bool, completion: RoutingCompletionBlock?) {
//        backtrack(to: ViewControllerStack.shared?.topmost(), request: request, animated: animated, completion: completion)
        backtrack(root: ViewControllerStack.shared?.root(), request: request, animated: animated, completion: completion)
    }

    open func backtrack(root viewController: UIViewController?, request: RoutingRequest, animated: Bool, completion: RoutingCompletionBlock?) {
        if request.host != defaults?["host"] {
            completion?(nil, false)
        } else {
            backtracked(viewController: viewController, request: request, animated: animated) { [weak self] found in
                if let found = found {
                    self?.unwind(from: ViewControllerStack.shared?.topmost(), to: found, completion: completion)
                } else {
                    completion?(nil, false)
                }
            }
        }
    }

    open func backtracked(viewController: UIViewController?, request: RoutingRequest, animated: Bool, completion: BacktrackRoutingCompletionBlock?) {
        if let destination = viewController as? NavigableProtocol {
            destination.navigate(to: request, animated: animated, completion: { [weak self] finalDestination, completed in
                if completed {
                    completion?(finalDestination as? UIViewController)
                } else {
                    self?.backtracked(presenting: viewController, request: request, animated: animated, completion: { [weak self] found in
                        if found != nil {
                            completion?(found)
                        } else {
                            self?.backtracked(tabbarController: viewController as? UITabBarController, index: 0, request: request, animated: animated) { [weak self] found in
                                if found != nil {
                                    completion?(found)
                                } else {
                                    self?.backtracked(navigationController: viewController as? UINavigationController, index: 0, request: request, animated: animated) { [weak self] found in
                                        if found != nil {
                                            completion?(found)
                                        } else {
                                            self?.backtracked(embeddingController: viewController as? UIViewControllerEmbeddingProtocol, index: 0, request: request, animated: animated, completion: { [weak self] found in
                                                if found != nil {
                                                    completion?(found)
                                                } else {
                                                    let temp: Any? = viewController
                                                    self?.backtracked(halfController: temp as? UIViewControllerHalfProtocol, request: request, animated: animated, completion: completion)
                                                }
                                            })
                                        }
                                    }
                                }
                            }
                        }
                    })
                }
            })
        } else {
            completion?(nil)
        }
    }

    open func backtracked(presenting: UIViewController?, request: RoutingRequest, animated: Bool, completion: BacktrackRoutingCompletionBlock?) {
        if let child = presenting?.presentedViewController {
            backtracked(viewController: child, request: request, animated: animated, completion: completion)
        } else {
            completion?(nil)
        }
    }

    open func backtracked(tabbarController: UITabBarController?, index: Int, request: RoutingRequest, animated: Bool, completion: BacktrackRoutingCompletionBlock?) {
        if let children = tabbarController?.children, index < children.count {
            let child = children[index]
            backtracked(viewController: child, request: request, animated: animated) { [weak self] found in
                if found != nil {
                    completion?(child)
                } else {
                    self?.backtracked(tabbarController: tabbarController, index: index + 1, request: request, animated: animated, completion: completion)
                }
            }
        } else {
            completion?(nil)
        }
    }

    open func backtracked(navigationController: UINavigationController?, index: Int, request: RoutingRequest, animated: Bool, completion: BacktrackRoutingCompletionBlock?) {
        if let children = navigationController?.viewControllers, index < children.count {
            let child = children[index]
            backtracked(viewController: child, request: request, animated: animated) { [weak self] found in
                if found != nil {
                    completion?(child)
                } else {
                    self?.backtracked(navigationController: navigationController, index: index + 1, request: request, animated: animated, completion: completion)
                }
            }
        } else {
            completion?(nil)
        }
    }

    open func backtracked(embeddingController: UIViewControllerEmbeddingProtocol?, index: Int, request: RoutingRequest, animated: Bool, completion: BacktrackRoutingCompletionBlock?) {
        var children: [UIViewController] = []
        if let embedded = embeddingController?.embedded {
            children.append(embedded)
        }
        if let floated = embeddingController?.floated {
            children.append(floated)
        }
        if index < children.count {
            let child = children[index]
            backtracked(viewController: child, request: request, animated: animated) { [weak self] found in
                if found != nil {
                    completion?(child)
                } else {
                    self?.backtracked(embeddingController: embeddingController, index: index + 1, request: request, animated: animated, completion: completion)
                }
            }
        } else {
            completion?(nil)
        }
    }

    open func backtracked(halfController: UIViewControllerHalfProtocol?, request: RoutingRequest, animated: Bool, completion: BacktrackRoutingCompletionBlock?) {
        if let child = halfController?.floatingManager?.halved {
            backtracked(viewController: child, request: request, animated: animated, completion: completion)
        } else {
            completion?(nil)
        }
    }

    open func backtrack(to viewController: UIViewController?, request: RoutingRequest, animated: Bool, completion: RoutingCompletionBlock?) {
        if let viewController = viewController {
            if let destination = viewController as? NavigableProtocol {
                destination.navigate(to: request, animated: animated, completion: { [weak self] _, completed in
                    if completed {
                        self?.unwind(from: ViewControllerStack.shared?.topmost(), to: viewController, completion: completion)
                    } else {
                        self?.backtrackParent(of: viewController, request: request, animated: animated, completion: completion)
                    }
                })
            } else {
                backtrackParent(of: viewController, request: request, animated: animated, completion: completion)
            }
        } else {
            completion?(self, false)
        }
    }

    open func backtrackParent(of viewController: UIViewController, request: RoutingRequest, animated: Bool, completion: RoutingCompletionBlock?) {
        if let nav = viewController.navigationController {
            backtrack(to: nav, request: request, animated: animated, completion: completion)
        } else if let presenting = viewController.presentingViewController {
            backtrack(to: presenting, request: request, animated: animated, completion: completion)
        } else if let tabbar = viewController.tabBarController {
            backtrack(to: tabbar, request: request, animated: animated, completion: completion)
        } else {
            // this is the root
            completion?(nil, false)
        }
    }

    open func unwind(from viewController: UIViewController?, to target: UIViewController, completion: RoutingCompletionBlock?) {
        if viewController !== target {
            if target.presentedViewController != nil {
                target.dismiss(animated: true, completion: nil)
            }
            target.navigationController?.popToViewController(target, animated: true)
            completion?(target, true)
        } else {
            completion?(viewController, true)
        }
    }

    override open func navigate(to map: RoutingMap, request: RoutingRequest, presentation: RoutingPresentation?, animated: Bool, completion: RoutingCompletionBlock?) {
        Console.shared.log(request.path)
        route(storyboardOrBuilder: map, request: request, presentation: presentation, animated: animated) { [weak self] object, completed in
            if completed {
                completion?(object, true)
            } else {
                self?.route(xib: map, request: request, animated: animated, completion: completion)
            }
        }
    }

    private func route(storyboardOrBuilder map: RoutingMap, request: RoutingRequest, presentation: RoutingPresentation?, animated: Bool, completion: RoutingCompletionBlock?) {
        loadViewController(from: map) { [weak self] viewController in
            if let viewController = viewController {
                self?.route(viewController: viewController, presentation: presentation ?? map.presentation, animated: animated) { object, success in
                    if let destination = (viewController as? NavigableProtocol) {
                        destination.navigate(to: request, animated: true, completion: completion)
                        ViewControllerStack.shared?.didShow(viewController: viewController)
                    } else if let embedder = viewController as? UIViewControllerEmbeddingProtocol {
                        self?.backtracked(embeddingController: embedder, index: 0, request: request, animated: true) { viewController in
                            if viewController != nil {
                                completion?(viewController, true)
                            } else {
                                completion?(nil, false)
                            }
                        }
                    } else {
                        completion?(object, success)
                    }
                }
            } else {
                completion?(nil, false)
            }
        }
    }

    internal func route(viewController: UIViewController, presentation: RoutingPresentation?, animated: Bool, completion: RoutingCompletionBlock?) {
        let presentation = presentation ?? defaultPresentation(for: viewController)
        switch presentation {
        case .root:
            root(viewController, animated: animated, completion: completion)

        case .show:
            show(viewController, animated: animated, completion: completion)

        case .detail:
            detail(viewController, animated: animated, completion: completion)

        case .prompt:
            prompt(viewController, animated: animated, completion: completion)

        case .callout:
            callout(viewController, animated: animated, completion: completion)

        case .float:
            float(viewController, animated: animated, completion: completion)

        case .half:
            half(viewController, animated: animated, completion: completion)

        case .embed:
            embed(viewController, animated: animated, completion: completion)

        case .drawer:
            drawer(viewController, animated: animated, completion: completion)

        case .popup:
            popup(viewController, animated: animated, completion: completion)

        case .presentOverFullScreen:
            presentOverFullScreen(viewController, animated: animated, completion: completion)
        }
    }

    private func defaultPresentation(for viewController: UIViewController) -> RoutingPresentation {
        if viewController is UINavigationController {
            return .prompt
        } else {
            return .show
        }
    }

    internal func root(_ viewController: UIViewController, animated: Bool, completion: RoutingCompletionBlock?) {
        completion?(nil, false)
    }

    private func show(_ viewController: UIViewController, animated: Bool, completion: RoutingCompletionBlock?) {
        if UIDevice.current.canSplit, let navigationController = ViewControllerStack.shared?.topmost()?.navigationController, let splitter = navigationController.splitViewController {
            if let nav = splitter.viewControllers.first as? UINavigationController {
                nav.pushViewController(viewController, animated: animated)
            } else {
                let nav = UIViewController.navigation(with: viewController)
                splitter.show(nav, sender: animated)
            }
            completion?(viewController, true)
        } else {
            push(viewController, animated: animated, completion: completion)
        }
    }

    private func detail(_ viewController: UIViewController, animated: Bool, completion: RoutingCompletionBlock?) {
        if UIDevice.current.canSplit {
            if let navigationController = ViewControllerStack.shared?.topmost()?.navigationController {
                if let splitter = navigationController.splitViewController {
                    let nav = UIViewController.navigation(with: viewController)
                    splitter.showDetailViewController(nav, sender: nil)
                    completion?(viewController, true)
                    return
                }
            }
        }
        push(viewController, animated: animated, completion: completion)
    }

    private func push(_ viewController: UIViewController, animated: Bool, completion: RoutingCompletionBlock?) {
        if let navigationController = ViewControllerStack.shared?.topmost()?.navigationController {
            navigationController.pushViewController(viewController, animated: animated)
            completion?(viewController, true)
        } else {
            completion?(nil, false)
        }
    }

    private func prompt(_ viewController: UIViewController, animated: Bool, completion: RoutingCompletionBlock?) {
        if let topmost = ViewControllerStack.shared?.topParent() {
            let navigationController = UIViewController.navigation(with: viewController)
            topmost.present(navigationController, animated: animated) {
            }
            completion?(viewController, true)
        } else {
            completion?(nil, false)
        }
    }

    private func callout(_ viewController: UIViewController, animated: Bool, completion: RoutingCompletionBlock?) {
        prompt(viewController, animated: animated, completion: completion)
    }

    private func half(_ viewController: UIViewController, animated: Bool, completion: RoutingCompletionBlock?) {
        if let topmost = ViewControllerStack.shared?.topParent() {
            if topmost.isPanModalPresented {
                let parent = topmost.presentingViewController
                topmost.dismiss(animated: true) { /* [weak self] in */
                    viewController.modalPresentationStyle = .custom
                    parent?.presentPanModal(viewController)
                    completion?(viewController, true)
                }
            } else {
                topmost.presentPanModal(viewController)
                completion?(viewController, true)
            }
//            if let floater = (topmost as Any?) as? UIViewControllerHalfProtocol {
//                floater.floatingManager?.half(viewController, animated: animated)
//            } else {
//                let navigationController = UIViewController.navigation(with: viewController)
//                topmost.present(navigationController, animated: animated) {
//                }
//            }
        } else {
            completion?(nil, false)
        }
    }

    private func popup(_ viewController: UIViewController, animated: Bool, completion: RoutingCompletionBlock?) {
        if let root = UIViewController.root() {
            // wrapper is necessary for custom transitions
            let wrapperViewController = UIViewController()
            wrapperViewController.modalPresentationStyle = .overFullScreen // or .custom for other presentation styles
            wrapperViewController.transitioningDelegate = fadeTransitioner

            // Add the UIHostingController to the wrapper UIViewController
            wrapperViewController.addChild(viewController)
            wrapperViewController.view.addSubview(viewController.view)
            viewController.didMove(toParent: wrapperViewController)

            // Ensure the hosting controller's view fills the wrapper view
            viewController.view.translatesAutoresizingMaskIntoConstraints = false
            viewController.view.snp.makeConstraints { $0.edges.equalTo(wrapperViewController.view) }

            // Present the wrapper UIViewController
            root.present(wrapperViewController, animated: true, completion: nil)

            completion?(viewController, true)
        } else {
            completion?(nil, false)
        }
    }

    private func presentOverFullScreen(_ viewController: UIViewController, animated: Bool, completion: RoutingCompletionBlock?) {
        if let topmost = ViewControllerStack.shared?.topParent() {
            let navigationController = UIViewController.navigation(with: viewController)
            navigationController.modalPresentationStyle = .overFullScreen
            // speeds up the animation by 2x
            navigationController.view.layer.speed = 2
            topmost.present(navigationController, animated: animated) {
            }
            completion?(viewController, true)
        } else {
            completion?(nil, false)
        }
    }

    private func float(_ viewController: UIViewController, animated: Bool, completion: RoutingCompletionBlock?) {
        if let topmost = ViewControllerStack.shared?.topParent() {
            if let embedder = topmost.parentViewControllerConforming(protocol: UIViewControllerEmbeddingProtocol.self) as? UIViewControllerEmbeddingProtocol, embedder.float(viewController, animated: true) {
            } else {
                let navigationController = UIViewController.navigation(with: viewController)
                topmost.present(navigationController, animated: animated) {
                }
            }
            completion?(viewController, true)
        } else {
            completion?(nil, false)
        }
    }

    private func floaterParent(viewController: UIViewController) -> UIViewControllerEmbeddingProtocol? {
        if let floater = viewController as? UIViewControllerEmbeddingProtocol {
            return floater
        }
        if let presenting = viewController.navigationController?.presentingViewController {
            return floaterParent(viewController: presenting)
        }
        if let presenting = viewController.presentingViewController {
            return floaterParent(viewController: presenting)
        }
        if let parent = viewController.parent {
            return floaterParent(viewController: parent)
        }
        if let tabbar = viewController.tabBarController {
            return floaterParent(viewController: tabbar)
        }
        return nil
    }

    private func embed(_ viewController: UIViewController, animated: Bool, completion: RoutingCompletionBlock?) {
        if let topmost = ViewControllerStack.shared?.topmost() {
            if let embedder: UIViewControllerEmbeddingProtocol = topmost.parentViewControllerConforming(protocol: UIViewControllerEmbeddingProtocol.self) as? UIViewControllerEmbeddingProtocol, embedder.embed(viewController, animated: true) {
            } else {
                let navigationController = UIViewController.navigation(with: viewController)
                topmost.present(navigationController, animated: animated) {
                }
            }
            completion?(viewController, true)
        } else {
            completion?(nil, false)
        }

//        if let root = ViewControllerStack.shared?.root() {
//            if let embedder = root as? UIViewControllerEmbeddingProtocol {
//                embedder.embeddingFloatingManager?.embed(viewController, animated: animated)
//            } else if let topmost = ViewControllerStack.shared?.topmost() {
//                let navigationController = UIViewController.navigation(with: viewController)
//                topmost.present(navigationController, animated: animated) {
//                }
//            }
//            completion?(viewController, true)
//        } else {
//            completion?(nil, false)
//        }
    }

    private func drawer(_ viewController: UIViewController, animated: Bool, completion: RoutingCompletionBlock?) {
        if let root = ViewControllerStack.shared?.root() {
            root.drawer()?.open(to: .left)
            completion?(viewController, true)
        } else {
            completion?(nil, false)
        }
    }

    private func route(xib map: RoutingMap, request: RoutingRequest, animated: Bool, completion: RoutingCompletionBlock?) {
        loadAction(from: map) { [weak self] action in
            if let action = action {
                self?.actions.append(action)
                weak var actionReference = action
                action.navigate(to: request, animated: animated) { data, success in
                    self?.actions.removeAll(where: { (actionInList) -> Bool in
                        actionReference === actionInList
                    })
                    completion?(data, success)
                }
            } else {
                assertionFailure("Action not found: \(String(describing: request.url))")
                completion?(nil, false)
            }
        }
    }

    public func viewController(for path: String, completion: @escaping ((UIViewController?) -> Void)) {
        let request = RoutingRequest(path: path)
        if let map = self.map(for: request) {
            loadViewController(from: map, completion: completion)
        } else {
            completion(nil)
        }
    }

    private func loadViewController(from map: RoutingMap, completion: @escaping ((UIViewController?) -> Void)) {
        if let builder = map.builder {
            ClassLoader.load(from: builder, completion: completion)
        } else if let storyboard = map.storyboard {
            let viewController = UIViewController.load(storyboard: storyboard)
            completion(viewController)
        } else {
            Console.shared.log("View Controller not found: \(map)")
            completion(nil)
        }
    }

    private func loadAction(from map: RoutingMap, completion: @escaping (((NSObject & NavigableProtocol)?) -> Void)) {
        if let xib = map.xib {
            let action: (NSObject & NavigableProtocol)? = XibLoader.load(from: xib)
            completion(action)
        } else if let builder = map.builder {
            ClassLoader.load(from: builder, completion: completion)
        } else {
            Console.shared.log("Action not found: \(map)")
            completion(nil)
        }
    }
}
