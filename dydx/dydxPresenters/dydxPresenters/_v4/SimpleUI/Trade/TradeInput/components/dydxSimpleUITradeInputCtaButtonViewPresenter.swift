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

    private enum OnboardingState {
        case newUser
        case needDeposit
        case readyToTrade
    }

    private let onboardingStatePublisher: AnyPublisher<OnboardingState, Never> =
        Publishers.CombineLatest(
            AbacusStateManager.shared.state.onboarded,
            AbacusStateManager.shared.state.selectedSubaccount
        ).map { onboarded, subaccount in
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

        Publishers
            .CombineLatest4(
                AbacusStateManager.shared.state.tradeInput.compactMap { $0 },
                AbacusStateManager.shared.state.validationErrors,
                AbacusStateManager.shared.state.configsAndAssetMap,
                onboardingStatePublisher)
            .sink { [weak self] tradeInput, tradeErrors, configsAndAssetMap, onboardingState in
                guard let self else { return }

                if let marketId = tradeInput.marketId {
                    self.update(tradeInput: tradeInput,
                                 tradeErrors: tradeErrors,
                                 configsAndAsset: configsAndAssetMap[marketId],
                                 onboardingState: onboardingState
                    )
                }

                let side = tradeInput.side
                switch side {
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
            }
            .store(in: &subscriptions)
    }

    private func update(tradeInput: TradeInput,
                        tradeErrors: [ValidationError],
                        configsAndAsset: MarketConfigsAndAsset?,
                        onboardingState: OnboardingState) {
        switch onboardingState {
        case .newUser:
            viewModel?.state = .enabled(DataLocalizer.localize(path: "APP.GENERAL.CONNECT_WALLET"))
        case .needDeposit:
            viewModel?.state = .enabled(DataLocalizer.localize(path: "APP.GENERAL.DEPOSIT_FUNDS"))
        case .readyToTrade:
            let firstBlockingError = tradeErrors.first { $0.type == ErrorType.required || $0.type == ErrorType.error }
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
    }

    private func trade(onboardingState: OnboardingState) {
        Router.shared?.navigate(to: RoutingRequest(path: "/action/dismiss"), animated: true) { _, _ in
            switch onboardingState {
            case .newUser:
                Router.shared?.navigate(to: RoutingRequest(path: "/onboard/wallets"), animated: true, completion: nil)
            case .needDeposit:
                Router.shared?.navigate(to: RoutingRequest(path: "/transfer"), animated: true, completion: nil)
            case .readyToTrade:
                HapticFeedback.shared?.notify(type: .success)
                Router.shared?.navigate(to: RoutingRequest(path: "/trade/simple/status"), animated: true, completion: nil)
            }
        }
    }
}
