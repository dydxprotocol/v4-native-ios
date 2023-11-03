//
//  MappedUIKitAppRouter.swift
//  PlatformRouting
//
//  Created by Qiang Huang on 10/12/18.
//  Copyright © 2018 dYdX. All rights reserved.
//

import RoutingKit
import UIToolkits

open class MappedUIKitAppRouter: MappedUIKitRouter {
    internal override func root(_ viewController: UIViewController, animated: Bool, completion: RoutingCompletionBlock?) {
        if let applicationDelegate = UIApplication.shared.delegate, let window = applicationDelegate.window {
            UIView.animate(window, type: .fade, direction: .none, duration: UIView.defaultAnimationDuration, animations: {
                if viewController is UITabBarController {
                    window?.rootViewController = viewController
                } else if viewController is UISplitViewController {
                    window?.rootViewController = viewController
                    (viewController as? UISplitViewController)?.delegate = self
                } else if viewController is UIViewControllerEmbeddingProtocol {
                    window?.rootViewController = viewController
                } else if viewController is UIViewControllerDrawerProtocol {
                    window?.rootViewController = viewController
                } else {
                    window?.rootViewController = UIViewController.navigation(with: viewController)
                }
            }) { _ in
                completion?(viewController, true)
            }
        } else {
            completion?(nil, false)
        }
    }

    private var primary: UIViewController?
    private var secondary: UIViewController?
}

extension MappedUIKitAppRouter: UISplitViewControllerDelegate {
    open func primaryViewController(forCollapsing splitViewController: UISplitViewController) -> UIViewController? {
        primary = splitViewController.viewControllers[0]
        secondary = splitViewController.viewControllers[1]
        return primary
    }

    open func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        return true
    }

    open func primaryViewController(forExpanding splitViewController: UISplitViewController) -> UIViewController? {
        return primary
    }

    open func splitViewController(_ splitViewController: UISplitViewController, separateSecondaryFrom primaryViewController: UIViewController) -> UIViewController? {
        return secondary
    }
}
