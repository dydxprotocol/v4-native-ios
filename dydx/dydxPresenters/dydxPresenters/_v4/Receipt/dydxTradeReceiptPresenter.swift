//
//  dydxTradeReceiptPresenter.swift
//  dydxPresenters
//
//  Created by John Huang on 1/4/23.
//

import Abacus
import dydxStateManager
import dydxViews
import ParticlesKit
import PlatformParticles
import PlatformUI
import RoutingKit
import SwiftUI
import Utilities
import Combine
import dydxFormatter

final class dydxTradeReceiptPresenter: dydxReceiptPresenter {
    private let tradeSummaryPublisher: AnyPublisher<(summary: TradeInputSummary?, marketId: String?), Never>

    init(tradeReceiptType: dydxValidationViewPresenter.TradeReceiptType) {
        switch tradeReceiptType {
        case .open:
            tradeSummaryPublisher = AbacusStateManager.shared.state.tradeInput
                .map { (summary: $0?.summary, marketId: $0?.marketId) }
                .eraseToAnyPublisher()
        case .close:
            tradeSummaryPublisher = AbacusStateManager.shared.state.closePositionInput
                .map { (summary: $0.summary, marketId: $0.marketId) }
                .eraseToAnyPublisher()
        }
        super.init()
    }

    override func start() {
        super.start()

        Publishers
            .CombineLatest(
                tradeSummaryPublisher,
                AbacusStateManager.shared.state.marketMap)
            .sink { [weak self] input, marketMap in
                if let tradeSummary = input.summary, let marketId = input.marketId, let market = marketMap[marketId] {
                    self?.updateTradingFee(tradeSummary: tradeSummary)
                    self?.updateExpectedPrice(tradeSummary: tradeSummary, market: market)
                    self?.updateTradingRewards(tradeSummary: tradeSummary)
                }
            }
            .store(in: &subscriptions)

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

    private func updateTradingFee(tradeSummary: TradeInputSummary?) {
        guard let tradeFee = tradeSummary?.fee else {
            feeViewModel.fee = nil
            return
        }

        feeViewModel.feeType = "Taker"  // TODO

        if tradeFee.doubleValue > 0, let value = dydxFormatter.shared.dollar(number: tradeFee.doubleValue, digits: 2) {
            feeViewModel.fee = .number(value)
        } else {
            feeViewModel.fee = .string(DataLocalizer.localize(path: "APP.GENERAL.FREE"))
        }
    }

    private func updateExpectedPrice(tradeSummary: TradeInputSummary?, market: PerpetualMarket) {
        let value = dydxFormatter.shared.dollar(number: tradeSummary?.price?.doubleValue, digits: market.configs?.displayTickSizeDecimals?.intValue ?? 0)
        expectedPriceViewModel.title = DataLocalizer.localize(path: "APP.GENERAL.PRICE")
        expectedPriceViewModel.value = value
    }

    private func updateTradingRewards(tradeSummary: TradeInputSummary?) {
        guard let rewards = tradeSummary?.reward?.doubleValue,
              let value = dydxFormatter.shared.localFormatted(number: abs(rewards), digits: 6)  else {
            rewardsViewModel.rewards = nil
            return
        }

        if rewards == 0 {
            rewardsViewModel.rewards = SignedAmountViewModel(text: "0", sign: .none, coloringOption: .signOnly)
        } else if rewards > 0 {
            rewardsViewModel.rewards = SignedAmountViewModel(text: value, sign: .plus, coloringOption: .signOnly)
        } else {
            rewardsViewModel.rewards = SignedAmountViewModel(text: value, sign: .minus, coloringOption: .signOnly)
        }
    }
}
