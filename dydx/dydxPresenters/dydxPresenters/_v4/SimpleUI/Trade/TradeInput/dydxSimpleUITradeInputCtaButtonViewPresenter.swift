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
    var viewModel: dydxTradeInputCtaButtonViewModel? { get }
}

class dydxSimpleUITradeInputCtaButtonViewPresenter: HostedViewPresenter<dydxTradeInputCtaButtonViewModel>, dydxSimpleUITradeInputCtaButtonViewPresenterProtocol {

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

        viewModel = dydxTradeInputCtaButtonViewModel()
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
            viewModel?.ctaButtonState = .enabled(DataLocalizer.localize(path: "APP.GENERAL.CONNECT_WALLET"))
        case .needDeposit:
            viewModel?.ctaButtonState = .enabled(DataLocalizer.localize(path: "APP.GENERAL.DEPOSIT_FUNDS"))
        case .readyToTrade:
            let firstBlockingError = tradeErrors.first { $0.type == ErrorType.required || $0.type == ErrorType.error }
            if firstBlockingError?.action != nil {
                viewModel?.ctaButtonState = .enabled(firstBlockingError?.resources.action?.localizedString)
            } else if tradeInput.size?.size?.doubleValue ?? 0 > 0 {
                if let firstBlockingError = firstBlockingError {
                    viewModel?.ctaButtonState = .disabled(firstBlockingError.resources.action?.localizedString)
                } else {
                    let localizePath: String?
                    switch tradeInput.side {
                    case .buy:
                        localizePath = "APP.TRADE.BUY_AMOUNT_ASSET"
                    case .sell:
                        localizePath = "APP.TRADE.SELL_AMOUNT_ASSET"
                    default:
                        localizePath = nil
                    }
                    let stepSize = configsAndAsset?.configs?.displayStepSizeDecimals?.intValue ?? 1
                    let amountText = dydxFormatter.shared.localFormatted(number: tradeInput.size?.size,
                                                                         digits: stepSize)
                    if let localizePath = localizePath, let amountText = amountText, let asset = configsAndAsset?.asset?.displayableAssetId {
                        let localizedString = DataLocalizer.localize(path: localizePath, params: ["AMOUNT": amountText, "ASSET": asset])
                        viewModel?.ctaButtonState = .enabled(localizedString)
                    } else {
                        viewModel?.ctaButtonState = .disabled()
                    }
                }
            } else {
                viewModel?.ctaButtonState = .disabled()
            }
        }
    }

    private func trade(onboardingState: OnboardingState) {
        switch onboardingState {
        case .newUser:
            Router.shared?.navigate(to: RoutingRequest(path: "/onboard/wallets"), animated: true, completion: nil)
        case .needDeposit:
            Router.shared?.navigate(to: RoutingRequest(path: "/transfer"), animated: true, completion: nil)
        case .readyToTrade:
            Router.shared?.navigate(to: RoutingRequest(path: "/trade/status"), animated: true, completion: nil)
        }
    }
}
