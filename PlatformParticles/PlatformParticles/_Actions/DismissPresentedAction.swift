//
//  DismissPresentedAction.swift
//  PlatformParticles
//
//  Created by Mike Maguire on 9/15/24.
//  Copyright © 2024 dYdX. All rights reserved.
//

import ParticlesKit
import RoutingKit
import Utilities

public class DismissPresentedActionBuilder: NSObject, ObjectBuilderProtocol {
    public func build<T>() -> T? {
        let action = DismissPresentedAction()
        return action as? T
    }
}

private class DismissPresentedAction: NSObject, NavigableProtocol {
    @objc open func navigate(to request: RoutingRequest?, animated: Bool, completion: RoutingCompletionBlock?) {
        if request?.path == "/action/dismiss_presented" {
            let viewController = UIViewController.topmost()
            if viewController?.presentingViewController !== nil {
                viewController?.dismiss(animated: true, completion: {
                    completion?(nil, true)
                })
            }
        } else {
            completion?(nil, false)
        }
    }
}
