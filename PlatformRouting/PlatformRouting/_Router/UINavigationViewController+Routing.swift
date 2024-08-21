//
//  UINavigationViewController+Routing.swift
//  PlatformRouting
//
//  Created by Qiang Huang on 11/24/18.
//  Copyright © 2018 dYdX. All rights reserved.
//

import RoutingKit
import UIKit

extension UINavigationController: NavigableProtocol {
    public func navigate(to request: RoutingRequest?, animated: Bool, completion: RoutingCompletionBlock?) {
        navigate(to: request, viewControllerIndex: 0, animated: animated, completion: completion)
    }

    public func navigate(to request: RoutingRequest?, viewControllerIndex: Int, animated: Bool, completion: RoutingCompletionBlock?) {
        if viewControllerIndex < viewControllers.count {
            let viewController = viewControllers[viewControllerIndex]
            if let destination = viewController as? NavigableProtocol {
                destination.navigate(to: request, animated: animated) { [weak self] _, completed in
                    if completed {
                        self?.popToViewController(viewController, animated: animated)
                        completion?(destination, true)
                    } else {
                        self?.navigate(to: request, viewControllerIndex: viewControllerIndex + 1, animated: animated, completion: completion)
                    }
                }
            } else {
                navigate(to: request, viewControllerIndex: viewControllerIndex + 1, animated: animated, completion: completion)
            }
        } else {
            completion?(nil, false)
        }
    }

    open override func showDetailViewController(_ vc: UIViewController, sender: Any?) {
    }
}
