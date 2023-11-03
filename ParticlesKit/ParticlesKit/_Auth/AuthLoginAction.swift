//
//  AuthLoginAction.swift
//  ParticlesKit
//
//  Created by Qiang Huang on 9/15/20.
//  Copyright © 2020 dYdX. All rights reserved.
//

import RoutingKit
import Utilities

open class AuthLoginAction: NSObject, NavigableProtocol {
    open func navigate(to request: RoutingRequest?, animated: Bool, completion: RoutingCompletionBlock?) {
        if request?.path == "/action/login" || request?.path == "/login" {
            if let provider = AuthService.shared.provider {
                provider.login { /* [weak self] */ successful in
                    completion?(nil, successful)
                }
            } else {
                completion?(nil, false)
            }
        } else {
            completion?(nil, false)
        }
    }
}
