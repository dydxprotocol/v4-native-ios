//
//  AuthLogoutAction.swift
//  ParticlesKit
//
//  Created by Qiang Huang on 9/15/20.
//  Copyright © 2020 dYdX. All rights reserved.
//

import RoutingKit
import Utilities

open class AuthLogoutAction: NSObject, NavigableProtocol {
    open func navigate(to request: RoutingRequest?, animated: Bool, completion: RoutingCompletionBlock?) {
        if request?.path == "/action/logout" || request?.path == "/logout" {
            if let provider = AuthService.shared.provider {
                if let token = provider.token {
                    provider.logout(token: token) { /* [weak self] */ successful in
                        completion?(nil, successful)
                    }
                } else {
                    completion?(nil, true)
                }
            } else {
                completion?(nil, true)
            }
        } else {
            completion?(nil, false)
        }
    }
}
