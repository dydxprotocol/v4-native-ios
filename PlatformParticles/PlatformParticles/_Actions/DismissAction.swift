//
//  DismissAction.swift
//  PlatformParticles
//
//  Created by Qiang Huang on 9/15/20.
//  Copyright © 2020 dYdX. All rights reserved.
//

import ParticlesKit
import RoutingKit
import Utilities

public class DismissActionBuilder: NSObject, ObjectBuilderProtocol {
    public func build<T>() -> T? {
        let action = DismissAction()
        return action as? T
    }
}

private class DismissAction: NSObject, NavigableProtocol {
    @objc open func navigate(to request: RoutingRequest?, animated: Bool, completion: RoutingCompletionBlock?) {
        if request?.path == "/action/dismiss" {
            let viewController = UIViewController.topmost()
            if let shouldPrioritizeDismiss = request?.params?["shouldPrioritizeDismiss"] as? Bool,
               shouldPrioritizeDismiss && viewController?.presentingViewController !== nil {
                viewController?.dismiss(animated: animated, completion: {
                    completion?(nil, true)
                })
            } else if viewController?.navigationController?.topViewController == viewController,
               viewController?.navigationController?.viewControllers.count ?? 0 > 1 {
                viewController?.navigationController?.popViewController(animated: animated)
            } else if viewController?.presentingViewController !== nil {
                viewController?.dismiss(animated: animated, completion: {
                    completion?(nil, true)
                })
            } else if viewController?.floatingParent !== nil {
                viewController?.move(to: .tip)
            }
        } else {
            completion?(nil, false)
        }
    }
}
