//
//  dydxSimpleUIBuyingPowerViewPresenter.swift
//  dydxPresenters
//
//  Created by Rui Huang on 16/01/2025.
//

import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI
import SwiftUI
import Combine
import dydxFormatter
import Abacus
import dydxStateManager

protocol dydxSimpleUIBuyingPowerView1PresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxSimpleUIBuyingPowerViewModel? { get }
}

class dydxSimpleUIBuyingPowerViewPresenter: HostedViewPresenter<dydxSimpleUIBuyingPowerViewModel>, dydxSimpleUIBuyingPowerView1PresenterProtocol {
    override init() {
        super.init()

        viewModel = dydxSimpleUIBuyingPowerViewModel()
    }

    override func start() {
        super.start()

        Publishers
            .CombineLatest(
                AbacusStateManager.shared.state.selectedSubaccountPositions,
                AbacusStateManager.shared.state.tradeInput)
            .sink { [weak self] positions, tradeInput in
                let marketId = tradeInput?.marketId ?? "ETH-USD"
                if let position = positions.first(where: { $0.id == marketId}) {
                    self?.updateBuyingPowerChange(buyingPower: position.buyingPower)
                }
            }
            .store(in: &subscriptions)
    }

    func updateBuyingPowerChange(buyingPower: TradeStatesWithDoubleValues) {
        let before: AmountTextModel?
        if let beforeAmount = buyingPower.current {
            before = AmountTextModel(amount: beforeAmount, tickSize: NSNumber(value: 0), requiresPositive: true)
        } else {
            before = nil
        }

        let after: AmountTextModel?
        if let afterAmount = buyingPower.postOrder, afterAmount != buyingPower.current {
            after = AmountTextModel(amount: afterAmount, tickSize: NSNumber(value: 0), requiresPositive: true)
        } else {
            after = nil
        }

        viewModel?.buyingPowerChange = dydxSimpleUIBuyingPowerViewModel.BuyingPowerChange(symbol: "USD", change: .init(before: before, after: after))
    }
}
