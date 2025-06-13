//
//  dydxPostOnboardingAction.swift
//  dydxPresenters
//
//  Created by Rui Huang on 24/12/2024.
//

import Foundation
import Utilities
import RoutingKit
import dydxStateManager
import Combine
import dydxFormatter

public class dydxPostOnboardingActionBuilder: NSObject, ObjectBuilderProtocol {
    public func build<T>() -> T? {
        let action = dydxPostOnboardingAction()
        return action as? T
    }
}

private class dydxPostOnboardingAction: NSObject, NavigableProtocol {
    private var subscriptions = Set<AnyCancellable>()

    func navigate(to request: RoutingRequest?, animated: Bool, completion: RoutingCompletionBlock?) {
        switch request?.path {
        case "/action/post_onboarding":
            let walletId = parser.asString(request?.params?["walletId"])
            if let ethereumAddress = parser.asString(request?.params?["ethereumAddress"]) {
                if let cosmoAddress = parser.asString(request?.params?["cosmoAddress"]),
                    let mnemonic = parser.asString(request?.params?["mnemonic"]) {
                    AbacusStateManager.shared.setV4(ethereumAddress: ethereumAddress, walletId: walletId, cosmoAddress: cosmoAddress, mnemonic: mnemonic, isNew: true)
                }
            }
            Router.shared?.navigate(to: RoutingRequest(path: "/"), animated: animated, completion: completion)
        default:
            completion?(nil, false)
        }
    }
}
