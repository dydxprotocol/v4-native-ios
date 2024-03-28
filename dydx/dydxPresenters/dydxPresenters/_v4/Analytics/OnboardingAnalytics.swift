//
//  OnboardingAnalytics.swift
//  dydxPresenters
//
//  Created by Rui Huang on 26/03/2024.
//

import Foundation
import Utilities
import dydxStateManager
import Combine

final class OnboardingAnalytics {

    // The three main OnboardingStates:
    /// - Disconnected
    /// - WalletConnected
    /// - AccountConnected
    private enum OnboardingState: String {
        /// User is disconnected.
        case disconnected = "Disconnected"

        /// Wallet is connected.
        case walletConnected = "WalletConnected"

        /// Account is connected.
        case accountConnected = "AccountConnected"
    }

    /// Enum representing the various steps in the onboarding process.
    enum OnboardingSteps: String {
        /// Step: Choose Wallet
        case chooseWallet = "ChooseWallet"

        /// Step: Key Derivation
        case keyDerivation = "KeyDerivation"

        /// Step: Acknowledge Terms
        case acknowledgeTerms = "AcknowledgeTerms"

        /// Step: Deposit Funds
        case depositFunds = "DepositFunds"
    }

    public var subscriptions = Set<AnyCancellable>()

    func log(step: OnboardingSteps) {
       AbacusStateManager.shared.state.currentWallet
            .prefix(1)
            .sink { wallet in
                let state: OnboardingState
                if wallet == nil {
                    state = .disconnected
                } else if (wallet?.cosmoAddress?.length ?? 0) > 0 {
                    state = .accountConnected
                } else {
                    state = .walletConnected
                }
                let data: [String: String] = [
                    "state": state.rawValue,
                    "step": step.rawValue
                ]
                Tracking.shared?.log(event: AnalyticsEvent.onboardingStepChanged.rawValue,
                                     data: data)
            }
            .store(in: &subscriptions)
    }
}
