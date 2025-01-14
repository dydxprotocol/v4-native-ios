//
//  dydxSwitchAppModeActionBuilder.swift
//  dydxPresenters
//
//  Created by Rui Huang on 13/01/2025.
//

import Foundation
import Utilities
import RoutingKit
import dydxStateManager
import Combine
import dydxViews

public class dydxSwitchAppModeActionBuilder: NSObject, ObjectBuilderProtocol {
    public func build<T>() -> T? {
        let action = dydxSwitchAppModeAction()
        return action as? T
    }
}

private class dydxSwitchAppModeAction: NSObject, NavigableProtocol {
    private var subscriptions = Set<AnyCancellable>()

    func navigate(to request: RoutingRequest?, animated: Bool, completion: RoutingCompletionBlock?) {
        switch request?.path {
        case "/action/mode/switch":
            if let mode = request?.params?["mode"] as? String, let appMode = AppMode(rawValue: mode) {
                if AppMode.current != appMode {
                    AppMode.current = appMode
                    Router.shared?.navigate(to: RoutingRequest(path: "/loading"), animated: true, completion: { _, _ in
                        Router.shared?.navigate(to: RoutingRequest(path: "/"), animated: true, completion: { _, _ in
                        })
                    })
                    completion?(nil, true)
                }
            } else {
                assertionFailure("mode not found in params dydxSwitchAppModeAction")
                completion?(nil, false)
            }
        default:
            completion?(nil, false)
        }
    }
}
