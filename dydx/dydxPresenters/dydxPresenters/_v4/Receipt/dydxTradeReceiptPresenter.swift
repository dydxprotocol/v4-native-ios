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
                .map { (summary: $0?.summary, marketId: $0?.marketId) }
                .eraseToAnyPublisher()
        }
        super.init()
    }

    override func start() {
        super.start()

        Publishers
            .CombineLatest3(
                tradeSummaryPublisher,
                AbacusStateManager.shared.state.selectedSubaccountPositions,
                AbacusStateManager.shared.state.marketMap)
            .sink { [weak self] input, positions, marketMap in
                let tradeSummary = input.summary
                let marketId = input.marketId
                let market = marketMap[marketId ?? ""]
                let position = positions.first(where: { $0.id == marketId })
                self?.updateExpectedPrice(tradeSummary: tradeSummary, market: market)
                self?.updateLiquidationPrice(position: position, market: market)
                self?.updatePositionMargin(position: position)
                self?.updatePositionLeverage(position: position)
                self?.updateTradingFee(tradeSummary: tradeSummary)
                self?.updateTradingRewards(tradeSummary: tradeSummary)
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

    private func updateExpectedPrice(tradeSummary: TradeInputSummary?, market: PerpetualMarket?) {
        let value = dydxFormatter.shared.dollar(number: tradeSummary?.price?.doubleValue, digits: market?.configs?.displayTickSizeDecimals?.intValue ?? 2)
        expectedPriceViewModel.title = DataLocalizer.localize(path: "APP.TRADE.EXPECTED_PRICE")
        expectedPriceViewModel.value = value
    }

    private func updateLiquidationPrice(position: SubaccountPosition?, market: PerpetualMarket?) {
        let title = DataLocalizer.localize(path: "APP.TRADE.LIQUIDATION_PRICE_SHORT")
        let unit = AmountTextModel.Unit.dollar
        let tickSize = market?.configs?.displayTickSizeDecimals?.intValue.asNsNumber ?? 2
        liquidationPriceViewModel.title = title
        liquidationPriceViewModel.value = createAmountChangeViewModel(title: title, tradeState: position?.liquidationPrice, tickSize: tickSize, unit: unit)
    }

    private func updatePositionMargin(position: SubaccountPosition?) {
        let title = DataLocalizer.localize(path: "APP.TRADE.POSITION_MARGIN")
        let unit = AmountTextModel.Unit.dollar
        positionMarginViewModel.title = title
        positionMarginViewModel.value = createAmountChangeViewModel(title: title, tradeState: position?.marginValue, tickSize: 2, unit: unit)
    }

    private func updatePositionLeverage(position: SubaccountPosition?) {
        let title = DataLocalizer.localize(path: "APP.TRADE.POSITION_LEVERAGE")
        let unit = AmountTextModel.Unit.multiplier
        positionLeverageViewModel.title = title
        positionLeverageViewModel.value = createAmountChangeViewModel(title: title, tradeState: position?.leverage, tickSize: 2, unit: unit, shouldUseAbsoluteValues: true)
    }

    private func createAmountChangeViewModel(title: String,
                                             tradeState: TradeStatesWithDoubleValues?,
                                             tickSize: NSNumber?,
                                             unit: AmountTextModel.Unit,
                                             shouldUseAbsoluteValues: Bool = false) -> AmountChangeModel {
        let currentValue = shouldUseAbsoluteValues ? tradeState?.current?.doubleValue.asNsNumber.abs() : tradeState?.current?.doubleValue.asNsNumber
        let postValue = shouldUseAbsoluteValues ? tradeState?.postOrder?.doubleValue.asNsNumber.abs() : tradeState?.postOrder?.doubleValue.asNsNumber
        let currentViewModel = currentValue == nil ? nil : AmountTextModel(amount: currentValue, unit: unit)
        let postViewModel = postValue == nil ? nil : AmountTextModel(amount: postValue, unit: unit)
        return AmountChangeModel(before: currentViewModel, after: postViewModel)
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
