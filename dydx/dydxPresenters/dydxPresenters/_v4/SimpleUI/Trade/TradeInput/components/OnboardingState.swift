//
//  OnboardingState.swift
//  dydxPresenters
//
//  Created by Rui Huang on 03/02/2025.
//

import Utilities
import Abacus
import Combine
import dydxStateManager
import dydxFormatter

enum OnboardingState {
    case newUser
    case needDeposit
    case readyToTrade

    static var onboardingStatePublisher: AnyPublisher<OnboardingState, Never> {
        Publishers.CombineLatest(
            AbacusStateManager.shared.state.onboarded,
            AbacusStateManager.shared.state.selectedSubaccount
        )
        .map { onboarded, subaccount in
            if onboarded {
                if subaccount?.equity?.current?.doubleValue ?? 0 > 0 {
                    .readyToTrade
                } else {
                    .needDeposit
                }
            } else {
                .newUser
            }
        }
        .removeDuplicates()
        .eraseToAnyPublisher()
    }
}
