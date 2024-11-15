//
//  dydxMarketStatsViewPresenter.swift
//  dydxPresenters
//
//  Created by Rui Huang on 10/11/22.
//

import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI
import Combine
import dydxStateManager
import Abacus
import dydxFormatter
import SwiftUI

protocol dydxMarketStatsViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxMarketStatsViewModel? { get }
}

class dydxMarketStatsViewPresenter: HostedViewPresenter<dydxMarketStatsViewModel>, dydxMarketStatsViewPresenterProtocol {
    @Published var marketId: String?

    override init() {
        super.init()

        viewModel = dydxMarketStatsViewModel()
    }

    override func start() {
        super.start()

        Publishers
            .CombineLatest3($marketId,
                            AbacusStateManager.shared.state.marketMap,
                            AbacusStateManager.shared.state.assetMap)
            .sink { [weak self] marketId, marketMap, assetMap in
                guard let marketId = marketId, let market = marketMap[marketId] else { return }
                let tickSizeNumDecimals = market.configs?.displayTickSizeDecimals?.intValue ?? 0
                let stepSizeNumDecimals = market.configs?.displayStepSizeDecimals?.intValue ?? 0
                self?.updateStats(market: market, asset: assetMap[market.assetId], stepSizeNumDecimals: stepSizeNumDecimals, tickSizeNumDecimals: tickSizeNumDecimals)
            }
            .store(in: &subscriptions)
    }

    private func updateStats(market: PerpetualMarket, asset: Asset?, stepSizeNumDecimals: Int, tickSizeNumDecimals: Int) {
        var items = [dydxMarketStatsViewModel.StatItem]()

        let oraclePrice = dydxFormatter.shared.dollar(number: market.oraclePrice?.doubleValue, digits: tickSizeNumDecimals) ?? "-"
        items += [
            .init(header: DataLocalizer.localize(path: "APP.TRADE.ORACLE_PRICE"),
                  value: SignedAmountViewModel(text: oraclePrice, sign: .none, coloringOption: .allText))
        ]

        let volume = dydxFormatter.shared.dollarVolume(number: market.perpetual?.volume24H) ?? "-"
        items += [
            .init(header: DataLocalizer.localize(path: "APP.TRADE.VOLUME_24H"),
                  value: SignedAmountViewModel(text: volume, sign: .none, coloringOption: .allText))
        ]

        let change: String
        if let value = market.priceChange24HPercent?.doubleValue {
            change = dydxFormatter.shared.percent(number: abs(value), digits: 2) ?? "-"
        } else {
            change = "-"
        }
        var sign = PlatformUISign(value: market.priceChange24HPercent?.doubleValue)
        items += [
            .init(header: DataLocalizer.localize(path: "APP.TRADE.CHANGE_24H"),
                  value: SignedAmountViewModel(text: change, sign: sign, coloringOption: .allText))
        ]

        let fundingRate: String
        if let value = market.perpetual?.nextFundingRate?.doubleValue {
            fundingRate = dydxFormatter.shared.percent(number: abs(value), digits: 6) ?? "-"
        } else {
            fundingRate = "-"
        }
        sign = PlatformUISign(value: market.perpetual?.nextFundingRate?.doubleValue)
        items += [
            .init(header: DataLocalizer.localize(path: "APP.TRADE.FUNDING_RATE"),
                  value: SignedAmountViewModel(text: fundingRate, sign: sign, coloringOption: .allText))
        ]

        let nextFundingViewModel: PlatformViewModel
        if let nextFundingAtMilliseconds = market.perpetual?.nextFundingAtMilliseconds {
            let nextFundingAt = Date(milliseconds: nextFundingAtMilliseconds.doubleValue)
            nextFundingViewModel = IntervalTextModel(date: nextFundingAt, direction: .countDown, format: .full)
        } else {
            // With no nextFundingAt, we will just count down to the next hour mark
            nextFundingViewModel = IntervalTextModel(date: nil, direction: .countDownToHour, format: .full)
        }

        items += [
            .init(header: DataLocalizer.localize(path: "APP.TRADE.NEXT_FUNDING"),
                  value: nextFundingViewModel)
        ]

        let openInterest = dydxFormatter.shared.localFormatted(number: market.perpetual?.openInterest, digits: stepSizeNumDecimals) ?? "-"
        let token: TokenTextViewModel?
        if let symbol = asset?.displayableAssetId {
            token = TokenTextViewModel(symbol: symbol)
        } else {
            token = nil
        }
        items += [
            .init(header: DataLocalizer.localize(path: "APP.TRADE.OPEN_INTEREST"),
                  value: SignedAmountViewModel(text: openInterest, sign: .none, coloringOption: .allText),
                  token: token)
        ]

        viewModel?.statItems = items
    }
}
