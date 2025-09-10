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
        if result.cosmoAddress != nil && result.dydxMnemonic != nil {
            onboardingAnalytics.log(step: .keyDerivation)
            if walletInstance == nil && result.walletId != "turnkey" {
                let accepted: (() -> Void) = {
                    Router.shared?.navigate(to: RoutingRequest(path: "/action/post_onboarding", params: ["result": result]), animated: true, completion: nil)
                }
                Router.shared?.navigate(to: RoutingRequest(path: "/onboard/tos", params: ["accepted": accepted]), animated: true, completion: nil)
            } else {
                Router.shared?.navigate(to: RoutingRequest(path: "/action/post_onboarding", params: ["result": result]), animated: true, completion: nil)
            }
        }
    }
}
