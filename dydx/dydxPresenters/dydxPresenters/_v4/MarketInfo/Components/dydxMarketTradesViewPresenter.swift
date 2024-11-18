//
//  dydxMarketTradesViewPresenter.swift
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

protocol dydxMarketTradesViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxMarketTradesViewModel? { get }
}

class dydxMarketTradesViewPresenter: HostedViewPresenter<dydxMarketTradesViewModel>, dydxMarketTradesViewPresenterProtocol {
    @Published var marketId: String?

    override init() {
        super.init()

        viewModel = dydxMarketTradesViewModel()
    }

    override func start() {
        super.start()

        Publishers
            .CombineLatest3($marketId.compactMap { $0 },
                           AbacusStateManager.shared.state.tradesMap,
                           AbacusStateManager.shared.state.marketMap)
            .sink { [weak self] marketId, tradesMap, marketMap in
                guard let trades = tradesMap[marketId], let configs = marketMap[marketId]?.configs else {
                    return
                }
                let stepSize = configs.displayStepSize?.decimalValue
                let tickSize = configs.displayTickSize?.decimalValue
                let trimmed = trades.prefix(99)     // show max of 99 only for better performance
                let maxSizeTrade = trimmed.max { lhs, rhs in
                    lhs.size < rhs.size
                }
                self?.viewModel = dydxMarketTradesViewModel()
                self?.viewModel?.tradeItems = trimmed.compactMap {
                    dydxMarketTradesViewModel.TradeItem(marketTrade: $0, stepSize: stepSize, tickSize: tickSize, maxSize: maxSizeTrade?.size)
                }
            }
            .store(in: &subscriptions)
    }
}

private extension dydxMarketTradesViewModel.TradeItem {
    init(marketTrade: MarketTrade, stepSize: Decimal? = nil, tickSize: Decimal? = nil, maxSize: Double? = nil) {
        let time = dydxFormatter.shared.clock(time: Date(milliseconds: marketTrade.createdAtMilliseconds))
        let stepSize = dydxFormatter.shared.format(decimal: stepSize)
        let size =  dydxFormatter.shared.localFormatted(number: NSNumber(value: marketTrade.size), size: stepSize)
        let tickSize = dydxFormatter.shared.format(decimal: tickSize ?? 0.01)
        let price = dydxFormatter.shared.dollar(number: NSNumber(value: marketTrade.price), size: tickSize)
        let side: SideTextViewModel?
        if marketTrade.resources.sideStringKey.uppercased() == "APP.GENERAL.BUY" {
            side = .init(side: .buy, coloringOption: .colored)
        } else if marketTrade.resources.sideStringKey.uppercased() == "APP.GENERAL.SELL" {
            side = .init(side: .sell, coloringOption: .colored)
        } else {
            side = .init(side: .custom("---"))
        }
        let sizePercent: Double
        if let maxSize = maxSize, maxSize > 0 {
            sizePercent = marketTrade.size / maxSize
        } else {
            sizePercent = 0
        }
        self.init(id: marketTrade.id,
                  time: time,
                  side: side,
                  price: price,
                  size: size,
                  sizePercent: sizePercent)
    }
}
