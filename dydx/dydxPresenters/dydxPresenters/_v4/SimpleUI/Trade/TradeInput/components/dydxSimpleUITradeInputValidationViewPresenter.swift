//
//  dydxSimpleUITradeInputValidationViewPresenter.swift
//  dydxPresenters
//
//  Created by Rui Huang on 02/01/2025.
//

import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI
import Abacus
import Combine
import dydxStateManager

protocol dydxSimpleUITradeInputValidationViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: ValidationErrorViewModel? { get }
}

class dydxSimpleUITradeInputValidationViewPresenter: HostedViewPresenter<ValidationErrorViewModel>, dydxSimpleUITradeInputValidationViewPresenterProtocol {
    override init() {
        super.init()

        viewModel = ValidationErrorViewModel()
    }

    override func start() {
        super.start()

        Publishers
            .CombineLatest(
                AbacusStateManager.shared.state.validationErrors,
                OnboardingState.onboardingStatePublisher
            )
            .sink { [weak self] errors, onboardingState in
                self?.update(errors: errors, onboardingState: onboardingState)
            }
            .store(in: &subscriptions)
    }

    private func update(errors: [ValidationError], onboardingState: OnboardingState) {
        switch onboardingState {
        case .needDeposit, .newUser:
            viewModel?.state = .none
        case .readyToTrade:
            let firstBlockingError = errors.first { $0.type == ErrorType.error }
            let firstWarning = errors.first { $0.type == ErrorType.warning }
            if let firstBlockingError = firstBlockingError {
                viewModel?.title = firstBlockingError.resources.title?.localizedString
                viewModel?.message = firstBlockingError.resources.text?.localizedString
                viewModel?.state = .error
                if let hyperlinkText = firstBlockingError.linkText,
                   let link = firstBlockingError.link {
                    viewModel?.link = ValidationErrorViewModel.Link(text: hyperlinkText) {
                        Router.shared?.navigate(to: URL(string: link), completion: nil)
                    }
                }
            } else if let firstWarning = firstWarning {
                viewModel?.title = firstWarning.resources.title?.localizedString
                viewModel?.message = firstWarning.resources.text?.localizedString
                viewModel?.state = .warning
                if let hyperlinkText = firstWarning.linkText,
                   let link = firstWarning.link {
                    viewModel?.link = ValidationErrorViewModel.Link(text: hyperlinkText) {
                        Router.shared?.navigate(to: URL(string: link), completion: nil)
                    }
                }
            } else {
                viewModel?.state = .none
            }
        }
    }
}
