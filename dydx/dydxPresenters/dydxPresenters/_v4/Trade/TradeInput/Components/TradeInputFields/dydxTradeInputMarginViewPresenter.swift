//
//  dydxTradeInputMarginViewPresenter.swift
//  dydxPresenters
//
//  Created by Rui Huang on 07/05/2024.
//

import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI
import dydxStateManager
import Abacus

protocol dydxTradeInputMarginViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxTradeInputMarginViewModel? { get }
}

class dydxTradeInputMarginViewPresenter: HostedViewPresenter<dydxTradeInputMarginViewModel>, dydxTradeInputMarginViewPresenterProtocol {
    override init() {
        super.init()

        viewModel = dydxTradeInputMarginViewModel()
    }

    override func start() {
        super.start()

        AbacusStateManager.shared.state.tradeInput
            .compactMap { $0 }
            .sink {[weak self] tradeInput in
                self?.update(withTradeInput: tradeInput)
            }
            .store(in: &subscriptions)

        viewModel?.marginModeAction = {
            Router.shared?.navigate(to: RoutingRequest(path: "/trade/margin_type"), animated: true, completion: nil)
        }
        viewModel?.marginLeverageAction = {
            Router.shared?.navigate(to: RoutingRequest(path: "/trade/target_leverage"), animated: true, completion: nil)
        }
    }

    private func update(withTradeInput tradeInput: Abacus.TradeInput) {
        viewModel?.marginMode = DataLocalizer.localize(path: "APP.GENERAL.\(tradeInput.marginMode.rawValue)")
        viewModel?.marginLeverage = "\(tradeInput.targetLeverage)×"
    }
}
