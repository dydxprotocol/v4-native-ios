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
import dydxAnalytics
import Abacus
import dydxViews

public final class OnboardingAnalytics {

    public init() {}

    public var subscriptions = Set<AnyCancellable>()

    public func log(step: AnalyticsEventV2.OnboardingStep) {
        AbacusStateManager.shared.state.currentWallet
            .prefix(1)
            .sink { wallet in
                let state: AnalyticsEventV2.OnboardingState
                if wallet == nil {
                    state = .disconnected
                } else if (wallet?.cosmoAddress?.length ?? 0) > 0 {
                    state = .accountConnected
                } else {
                    state = .walletConnected
                }
                Tracking.shared?.logSharedEvent(ClientTrackableEventType.OnboardingStepChanged(step: step.rawValue, state: state.rawValue))
            }
            .store(in: &subscriptions)
    }
}
