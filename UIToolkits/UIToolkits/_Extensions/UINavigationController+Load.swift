//
//  UINavigationController+Load.swift
//  UIToolkits
//
//  Created by Qiang Huang on 9/12/19.
//  Copyright © 2019 dYdX. All rights reserved.
//

public extension UINavigationController {
    @objc static func loadNavigator(storyboard: String?) -> UINavigationController? {
        if let storyboard = storyboard, UIDevice.current.userInterfaceIdiom == .pad {
            if let nav = UIViewController.load(storyboard: "\(storyboard)-iPad") as? UINavigationController {
                return nav
            }
        }
        return UIViewController.load(storyboard: storyboard) as? UINavigationController
    }

    @objc static func load(storyboard: String?, with viewController: UIViewController?) -> UINavigationController? {
        if let viewController = viewController {
            if let navigationController = viewController as? UINavigationController {
                return navigationController
            } else {
                if let navigationController = loadNavigator(storyboard: storyboard) {
                    navigationController.viewControllers = [viewController]
                    return navigationController
                }
                return UINavigationController(rootViewController: viewController)
            }
        }
        return nil
    }
}
