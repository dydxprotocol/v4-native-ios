//
//  UISplitViewController+Routing.swift
//  PlatformRouting
//
//  Created by Qiang Huang on 12/16/18.
//  Copyright © 2018 dYdX. All rights reserved.
//

import RoutingKit
import UIKit

extension UISplitViewController: NavigableProtocol {
    public func navigate(to request: RoutingRequest?, animated: Bool, completion: RoutingCompletionBlock?) {
        navigate(to: request, viewControllerIndex: 0, animated: animated, completion: completion)
    }

    public func navigate(to request: RoutingRequest?, viewControllerIndex: Int, animated: Bool, completion: RoutingCompletionBlock?) {
        if viewControllerIndex < viewControllers.count {
            let viewController = viewControllers[viewControllerIndex]
            if let destination = viewController as? NavigableProtocol {
                destination.navigate(to: request, animated: animated) { [weak self] _, completed in
                    if completed {
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
