//
//  UITabBarController+Routing.swift
//  PlatformRouting
//
//  Created by Qiang Huang on 11/24/18.
//  Copyright © 2019 dYdX. All rights reserved.
//

import RoutingKit
import UIKit

extension UITabBarController: NavigableProtocol {
    public var history: RoutingRequest? {
        return RoutingRequest(path: "/")
    }

    public func navigate(to request: RoutingRequest?, animated: Bool, completion: RoutingCompletionBlock?) {
        if request?.path == "/" {
            completion?(self, true)
        } else {
            if let presented = presentedViewController as? NavigableProtocol {
                presented.navigate(to: request, animated: animated) { [weak self] _, completed in
                    if completed {
                        completion?(presented, true)
                    } else {
                        self?.navigate(to: request, viewControllerIndex: 0, animated: animated, completion: completion)
                    }
                }
            } else {
                navigate(to: request, viewControllerIndex: 0, animated: animated, completion: completion)
            }
        }
    }

    public func navigate(to request: RoutingRequest?, viewControllerIndex: Int, animated: Bool, completion: RoutingCompletionBlock?) {
        if viewControllerIndex < viewControllers?.count ?? 0 {
            if let destination = viewControllers?[viewControllerIndex] as? NavigableProtocol {
                destination.navigate(to: request, animated: animated) { [weak self] _, completed in
                    if completed {
                        self?.selectedIndex = viewControllerIndex
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
}
