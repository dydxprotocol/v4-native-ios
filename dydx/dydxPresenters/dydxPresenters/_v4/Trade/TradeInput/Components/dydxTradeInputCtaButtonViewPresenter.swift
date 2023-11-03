//
//  dydxTradeInputCtaButtonViewPresenter.swift
//  dydxPresenters
//
//  Created by Rui Huang on 1/14/23.
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

protocol dydxTradeInputCtaButtonViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxTradeInputCtaButtonViewModel? { get }
}

class dydxTradeInputCtaButtonViewPresenter: HostedViewPresenter<dydxTradeInputCtaButtonViewModel>, dydxTradeInputCtaButtonViewPresenterProtocol {
    override init() {
        super.init()

        viewModel = dydxTradeInputCtaButtonViewModel()
        viewModel?.ctaAction = {[weak self] in
            self?.trade()
        }
    }

    override func start() {
        super.start()

        Publishers
            .CombineLatest(
                AbacusStateManager.shared.state.tradeInput.compactMap { $0 },
                AbacusStateManager.shared.state.validationErrors)
            .sink { [weak self] tradeInput, tradeErrors in
                self?.update(tradeInput: tradeInput, tradeErrors: tradeErrors)
            }
            .store(in: &subscriptions)
    }

    private func update(tradeInput: TradeInput, tradeErrors: [ValidationError]) {
        let firstBlockingError = tradeErrors.first { $0.type == ErrorType.required || $0.type == ErrorType.error }
        if firstBlockingError?.action != nil {
            viewModel?.ctaButtonState = .enabled(firstBlockingError?.resources.action?.localizedString)
        } else if tradeInput.size?.size?.doubleValue ?? 0 > 0 {
            if let firstBlockingError = firstBlockingError {
                viewModel?.ctaButtonState = .disabled(firstBlockingError.resources.action?.localizedString)
            } else {
                var localizePath: String = "APP.TRADE.PLACE_TRADE"
                if let tradeInputType = tradeInput.type {
                    switch tradeInputType {
                    case .limit: localizePath = "APP.TRADE.PLACE_LIMIT_ORDER"
                    case .market: localizePath = "APP.TRADE.PLACE_MARKET_ORDER"
                    case .stoplimit: localizePath = "APP.TRADE.PLACE_STOP_LIMIT_ORDER"
                    case .stopmarket: localizePath = "APP.TRADE.PLACE_STOP_MARKET_ORDER"
                    case .takeprofitlimit: localizePath = "APP.TRADE.PLACE_TAKE_PROFIT_LIMIT_ORDER"
                    case .takeprofitmarket: localizePath = "APP.TRADE.PLACE_TAKE_PROFIT_MARKET_ORDER"
                    case .trailingstop: localizePath = "APP.TRADE.PLACE_TRAILING_STOP_ORDER"
                    default: break
                    }
                }
                viewModel?.ctaButtonState = .enabled(DataLocalizer.localize(path: localizePath))
            }
        } else {
            viewModel?.ctaButtonState = .disabled()
        }
    }

    private func trade() {
        Publishers.CombineLatest(
            AbacusStateManager.shared.state.onboarded,
            AbacusStateManager.shared.state.selectedSubaccount
        )
        .prefix(1)
        .sink { onboarded, subaccount in
            if onboarded {
                if subaccount?.equity?.current?.doubleValue ?? 0 > 0 {
                    Router.shared?.navigate(to: RoutingRequest(path: "/trade/status"), animated: true, completion: nil)
                } else {
                    Router.shared?.navigate(to: RoutingRequest(path: "/transfer"), animated: true, completion: nil)
                }
            } else {
                Router.shared?.navigate(to: RoutingRequest(path: "/onboard/wallets"), animated: true, completion: nil)
            }
        }
        .store(in: &subscriptions)
    }
}
