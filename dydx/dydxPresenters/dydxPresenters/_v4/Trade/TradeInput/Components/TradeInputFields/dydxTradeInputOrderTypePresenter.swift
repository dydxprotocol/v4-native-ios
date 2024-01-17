//
//  dydxTradeInputTypePresenter.swift
//  dydxPresenters
//
//  Created by John Huang on 1/4/23.
//

import Abacus
import dydxFormatter
import dydxStateManager
import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI
import Combine

internal protocol dydxTradeOrderInputTypeViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxTradeInputOrderTypeViewModel? { get }
}

internal class dydxTradeInputOrderTypeViewPresenter: HostedViewPresenter<dydxTradeInputOrderTypeViewModel>, dydxTradeOrderInputTypeViewPresenterProtocol {
    override init() {
        super.init()

        viewModel = dydxTradeInputOrderTypeViewModel()
        viewModel?.onEdited = {value in
            AbacusStateManager.shared.trade(input: value, type: TradeInputField.type)
            Tracking.shared?.log(event: "TradeOrderTypeSelected", data: ["type": value?.uppercased() as Any])
        }
    }

    override func start() {
        super.start()

        AbacusStateManager.shared.state.tradeInput.compactMap { $0 }
            .sink { [weak self] (tradeInput: TradeInput) in
                self?.update(tradeInput: tradeInput)
            }
            .store(in: &subscriptions)
    }

    private func update(tradeInput: TradeInput) {
        if !dydxBoolFeatureFlag.enable_spot_experience.isEnabled {
            if let typeOptions = tradeInput.options?.typeOptions {
                viewModel?.options = AbacusUtils.translate(options: typeOptions)
            }
            viewModel?.value = tradeInput.type?.rawValue
        }
    }
}
