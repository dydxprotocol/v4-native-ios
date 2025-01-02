//
//  dydxReceiptPresenter.swift
//  dydxPresenters
//
//  Created by Rui Huang on 4/14/23.
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

protocol dydxReceiptPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxReceiptViewModel? { get }
}

class dydxReceiptPresenter: HostedViewPresenter<dydxReceiptViewModel>, dydxReceiptPresenterProtocol {
    @Published var buyingPowerViewModel = dydxReceiptBuyingPowerViewModel()
    let marginUsageViewModel = dydxReceiptMarginUsageViewModel()
    let feeViewModel = dydxReceiptFeeViewModel()
    let expectedPriceViewModel = dydxReceiptItemViewModel()
    let liquidationPriceViewModel = dydxReceiptChangeItemView()
    let positionMarginViewModel = dydxReceiptChangeItemView()
    let positionLeverageViewModel = dydxReceiptChangeItemView()
    let bridgefeeViewModel = dydxReceiptFeeViewModel()
    let exchangeRateViewModel = dydxReceiptItemViewModel()
    let exchangeReceivedViewModel = dydxReceiptItemViewModel()
    let slippageViewModel = dydxReceiptItemViewModel()
    let equlityViewModel = dydxReceiptEquityViewModel()
    let rewardsViewModel = dydxReceiptRewardsViewModel()
    let transferDurationViewModel = dydxReceiptItemViewModel()

    override init() {
        super.init()

        viewModel = dydxReceiptViewModel()

        equlityViewModel.usdcTokenName = dydxTokenConstants.usdcTokenName
        rewardsViewModel.nativeTokenLogoUrl = dydxTokenConstants.nativeTokenLogoUrl
    }

    override func start() {
        super.start()

        AbacusStateManager.shared.state.receipts
            .sink { [weak self] (lines: [ReceiptLine]) in
                self?.updateLines(lines: lines)
            }
            .store(in: &subscriptions)

        AbacusStateManager.shared.state.selectedSubaccount
            .compactMap { $0 }
            .sink { [weak self] account in
                self?.updateMarginUsageChange(account: account)
                self?.updateEquityChange(account: account)
            }
            .store(in: &subscriptions)
    }

    private func updateLines(lines: [ReceiptLine]) {
        viewModel?.children = lines.compactMap { (line: Abacus.ReceiptLine) -> PlatformViewModel? in
            switch line {
            case .buyingpower:
                return buyingPowerViewModel
            case .marginusage:
                return marginUsageViewModel
            case .fee:
                return feeViewModel
            case .expectedprice:
                return expectedPriceViewModel
            case .liquidationprice:
                return liquidationPriceViewModel
            case .positionmargin:
                return positionMarginViewModel
            case .positionleverage:
                return positionLeverageViewModel
            case .equity:
                return equlityViewModel
            case .exchangerate:
                return exchangeRateViewModel
            case .exchangereceived:
                return exchangeReceivedViewModel
            case .transferrouteestimatedduration:
                return transferDurationViewModel
            case .bridgefee:
                return bridgefeeViewModel
            case .slippage:
                return slippageViewModel
            case .total:
                return nil
            case .walletbalance:
                return nil
            case .reward:
                return rewardsViewModel
            case .gasfee:
                return nil
            default:
                return nil
            }
        }
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

        buyingPowerViewModel.buyingPowerChange = dydxReceiptBuyingPowerViewModel.BuyingPowerChange(symbol: "ETH", change: .init(before: before, after: after))
    }

    private func updateMarginUsageChange(account: Subaccount) {
        let before: MarginUsageModel?
        if let beforeAmount = account.marginUsage?.current {
            before = MarginUsageModel(percent: beforeAmount.doubleValue)
        } else {
            before = nil
        }

        let after: MarginUsageModel?
        if let afterAmount = account.marginUsage?.postOrder, afterAmount != account.marginUsage?.current {
            after = MarginUsageModel(percent: afterAmount.doubleValue)
        } else {
            after = nil
        }

        marginUsageViewModel.marginChange = MarginUsageChangeModel(before: before, after: after)
    }

    private func updateEquityChange(account: Subaccount) {
        let before: AmountTextModel?
        if let beforeAmount = account.equity?.current?.doubleValue {
            before = AmountTextModel(amount: NSNumber(floatLiteral: beforeAmount), tickSize: NSNumber(floatLiteral: 0.01))
        } else {
            before = nil
        }
        let after: AmountTextModel?
        if let afterAmount = account.equity?.postOrder?.doubleValue, afterAmount != account.equity?.current?.doubleValue {
            after = AmountTextModel(amount: NSNumber(floatLiteral: afterAmount), tickSize: NSNumber(floatLiteral: 0.01))
        } else {
            after = nil
        }

        equlityViewModel.equityChange = .init(before: before, after: after)
    }
}
