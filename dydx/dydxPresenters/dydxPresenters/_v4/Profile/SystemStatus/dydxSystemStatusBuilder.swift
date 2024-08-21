//
//  dydxSystemStatusBuilder.swift
//  dydxPresenters
//
//  Created by Rui Huang on 8/29/23.
//

import ParticlesKit
import RoutingKit
import Utilities
import Abacus
import dydxStateManager

public class dydxSystemStatusBuilder: NSObject, ObjectBuilderProtocol {
    public func build<T>() -> T? {
        let action = SystemStatusAction()
        return action as? T
    }
}

private class SystemStatusAction: NSObject, NavigableProtocol {
     func navigate(to request: RoutingRequest?, animated: Bool, completion: RoutingCompletionBlock?) {
        if request?.path == "/settings/status" {
            if let statusPageUrl = AbacusStateManager.shared.environment?.links?.statusPage ?? AbacusStateManager.shared.environment?.links?.community,
               let url = URL(string: statusPageUrl),
                URLHandler.shared?.canOpenURL(url) ?? false {
                URLHandler.shared?.open(url) { success in
                    completion?(nil, success)
                }
            } else {
                completion?(nil, false)
            }
        } else {
            completion?(nil, false)
        }
    }
}
