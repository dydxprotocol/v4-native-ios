//
//  dydxSimpleUITradeInputCtaButtonViewPresenter.swift
//  dydxPresenters
//
//  Created by Rui Huang on 03/01/2025.
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
import dydxFormatter

protocol dydxSimpleUITradeInputCtaButtonViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxSimpleUITradeInputCtaButtonView? { get }
}

class dydxSimpleUITradeInputCtaButtonViewPresenter: HostedViewPresenter<dydxSimpleUITradeInputCtaButtonView>, dydxSimpleUITradeInputCtaButtonViewPresenterProtocol {
    @Published var tradeType: TradeSubmission.TradeType = .trade

    private enum OnboardingState {
        case newUser
        case needDeposit
        case readyToTrade
    }

    private let onboardingStatePublisher: AnyPublisher<OnboardingState, Never> =
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

    override init() {
        super.init()

        viewModel = dydxSimpleUITradeInputCtaButtonView()
    }

    override func start() {
        super.start()

        let inputsPublisher = Publishers
            .CombineLatest3(
                $tradeType,
            AbacusStateManager.shared.state.tradeInput,
            AbacusStateManager.shared.state.closePositionInput)
            .map { ($0, $1, $2) }
            .eraseToAnyPublisher()

        Publishers
            .CombineLatest3(
                inputsPublisher,
                AbacusStateManager.shared.state.validationErrors,
                onboardingStatePublisher)
            .sink { [weak self] inputs, errors, onboardingState in
                guard let self else { return }
                let (tradeType, tradeInput, closePositionInput) = inputs

                switch tradeType {
                case .trade:
                    guard let tradeInput else {
                        return
                    }
                    self.update(tradeInput: tradeInput,
                                errors: errors,
                                onboardingState: onboardingState)
                    switch tradeInput.side {
                    case .buy:
                        self.viewModel?.side = .BUY
                    case .sell:
                        self.viewModel?.side = .SELL
                    default:
                        break
                    }
                    self.viewModel?.ctaAction = { [weak self] in
                        self?.trade(onboardingState: onboardingState)
                    }
                case .closePosition:
                    guard let closePositionInput else {
                        return
                    }
                    self.update(closePositionInput: closePositionInput,
                                errors: errors)

                    self.viewModel?.ctaAction = { [weak self] in
                        self?.closePosition()
                    }
                }
            }
            .store(in: &subscriptions)
    }

    private func update(closePositionInput: ClosePositionInput,
                        errors: [ValidationError]) {
        let firstBlockingError = errors.first { $0.type == ErrorType.required || $0.type == ErrorType.error }
        if firstBlockingError?.action != nil {
            viewModel?.state = .enabled(firstBlockingError?.resources.action?.localizedString)
        } else if closePositionInput.size?.size?.doubleValue ?? 0 > 0 {
            if let firstBlockingError = firstBlockingError {
                viewModel?.state = .disabled(firstBlockingError.resources.action?.localizedString)
            } else {
                viewModel?.state = .slider
            }
        } else {
            viewModel?.state = .disabled()
        }
        viewModel?.isClosePosition = true
    }

    private func closePosition() {
        navigate(to: RoutingRequest(path: "/action/dismiss"), animated: true) { _, _ in
            HapticFeedback.shared?.notify(type: .success)
            self.navigate(to: RoutingRequest(path: "/closePosition/simple/status"), animated: true, completion: nil)
        }
    }

    private func update(tradeInput: TradeInput,
                        errors: [ValidationError],
                        onboardingState: OnboardingState) {
        switch onboardingState {
        case .newUser:
            viewModel?.state = .enabled(DataLocalizer.localize(path: "APP.GENERAL.CONNECT_WALLET"))
        case .needDeposit:
            viewModel?.state = .enabled(DataLocalizer.localize(path: "APP.GENERAL.DEPOSIT_FUNDS"))
        case .readyToTrade:
            let firstBlockingError = errors.first { $0.type == ErrorType.required || $0.type == ErrorType.error }
            if firstBlockingError?.action != nil {
                viewModel?.state = .enabled(firstBlockingError?.resources.action?.localizedString)
            } else if tradeInput.size?.size?.doubleValue ?? 0 > 0 {
                if let firstBlockingError = firstBlockingError {
                    viewModel?.state = .disabled(firstBlockingError.resources.action?.localizedString)
                } else {
                    viewModel?.state = .slider
                }
            } else {
                viewModel?.state = .disabled()
            }
        }

        viewModel?.isClosePosition = false
    }

    private func trade(onboardingState: OnboardingState) {
        navigate(to: RoutingRequest(path: "/action/dismiss"), animated: true) {  _, _ in
            switch onboardingState {
            case .newUser:
                self.navigate(to: RoutingRequest(path: "/onboard/wallets"), animated: true, completion: nil)
            case .needDeposit:
                self.navigate(to: RoutingRequest(path: "/transfer"), animated: true, completion: nil)
            case .readyToTrade:
                HapticFeedback.shared?.notify(type: .success)
                self.navigate(to: RoutingRequest(path: "/trade/simple/status"), animated: true, completion: nil)
            }
        }
    }
}
