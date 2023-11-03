//
//  DebugEnableAction.swift
//  PlatformRouting
//
//  Created by Qiang Huang on 7/21/20.
//  Copyright © 2020 dYdX. All rights reserved.
//

import RoutingKit
import Utilities

public class DebugEnableActionBuilder: NSObject, ObjectBuilderProtocol {
    public func build<T>() -> T? {
        let action = DebugEnableAction()
        return action as? T
    }
}

open class DebugEnableAction: NSObject, NavigableProtocol {
    open func navigate(to request: RoutingRequest?, animated: Bool, completion: RoutingCompletionBlock?) {
        switch request?.path {
        case "/action/debug/enable":
            UserDefaults.standard.set(true, forKey: DebugEnabled.key)
            completion?(nil, true)

        default:
            completion?(nil, false)
        }
    }
}
