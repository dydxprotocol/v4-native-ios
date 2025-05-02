//
//  dydxOnboardingCompletion.swift
//  dydxPresenters
//
//  Created by Rui Huang on 02/05/2025.
//

import Foundation
import dydxStateManager
import RoutingKit
import dydxCartera

struct dydxOnboardCompletion {
    static func finish(walletInstance: dydxWalletInstance?,
                       result: dydxWalletSetup.SetupResult,
                       onboardingAnalytics: OnboardingAnalytics = .init()) {
        if let cosmoAddress = result.cosmoAddress, let mnemonic = result.mnemonic {
            onboardingAnalytics.log(step: .keyDerivation)
            if walletInstance == nil {
                let accepted: (() -> Void) = {
                    Router.shared?.navigate(to: RoutingRequest(path: "/action/post_onboarding", params: ["ethereumAddress": result.ethereumAddress, "cosmoAddress": cosmoAddress, "mnemonic": mnemonic, "walletId": result.walletId ?? ""]), animated: true, completion: nil)
                }
                Router.shared?.navigate(to: RoutingRequest(path: "/onboard/tos", params: ["accepted": accepted]), animated: true, completion: nil)
            } else {
                Router.shared?.navigate(to: RoutingRequest(path: "/action/post_onboarding", params: ["ethereumAddress": result.ethereumAddress, "cosmoAddress": cosmoAddress, "mnemonic": mnemonic, "walletId": result.walletId ?? ""]), animated: true, completion: nil)
            }
        }
    }
}
