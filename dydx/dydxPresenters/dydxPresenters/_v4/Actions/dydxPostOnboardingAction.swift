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
import dydxCartera

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
            if let result = request?.params?["result"] as? dydxWalletSetup.SetupResult,
               let cosmosAddress = result.cosmoAddress, let dydxMnemonic = result.dydxMnemonic {
                AbacusStateManager.shared.setV4(ethereumAddress: result.ethereumAddress,
                                                walletId: result.walletId,
                                                cosmoAddress: cosmosAddress,
                                                dydxMnemonic: dydxMnemonic,
                                                isNew: true,
                                                svmAddress: result.svmAddress,
                                                avalancheAddress: result.avalancheAddress,
                                                sourceWalletMnemonic: result.sourceWalletMnemonic,
                                                loginMethod: result.loginMethod,
                                                userEmail: result.userEmail)

                Router.shared?.navigate(to: RoutingRequest(path: "/"), animated: animated, completion: completion)

                if result.walletId == "turnkey" {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        Router.shared?.navigate(to: RoutingRequest(path: "/onboard/deposit_prompt"), animated: true, completion: nil)
                    }
                }
            }
        default:
            completion?(nil, false)
        }
    }
}
