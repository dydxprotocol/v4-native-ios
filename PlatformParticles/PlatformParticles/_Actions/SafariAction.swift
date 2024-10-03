//
//  SafariAction.swift
//  PlatformParticles
//
//  Created by John Huang on 4/25/22.
//  Copyright © 2022 dYdX Trading Inc. All rights reserved.
//

import ParticlesKit
import RoutingKit
import Utilities

public class SafariActionBuilder: NSObject, ObjectBuilderProtocol {
    public func build<T>() -> T? {
        let action = SafariAction()
        return action as? T
    }
}

open class SafariAction: NSObject, NavigableProtocol {
    @objc open func navigate(to request: RoutingRequest?, animated: Bool, completion: RoutingCompletionBlock?) {
        if let url = request?.url {
            URLHandler.shared?.open(url, completionHandler: nil)
        } else {
            completion?(nil, false)
        }
    }
}
