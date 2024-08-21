//
//  dydOrderbookGroupViewPresenter.swift
//  dydxPresenters
//
//  Created by Rui Huang on 9/30/23.
//

import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI
import Abacus
import dydxStateManager
import dydxFormatter
import Combine

protocol dydxOrderbookGroupViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxOrderbookGroupViewModel? { get }
}

class dydxOrderbookGroupViewPresenter: HostedViewPresenter<dydxOrderbookGroupViewModel>, dydxOrderbookGroupViewPresenterProtocol {
    @Published var marketId: String?

    override init() {
        super.init()

        viewModel = dydxOrderbookGroupViewModel()
    }

    override func start() {
        super.start()

        Publishers
            .CombineLatest3(
                $marketId,
                AbacusStateManager.shared.state.marketMap,
                AbacusStateManager.shared.state.orderbooksMap
            )
            .sink { [weak self] marketId, marketMap, orderbooksMap in
                if let marketId = marketId {
                    let market = marketMap[marketId]
                    let orderbook = orderbooksMap[marketId]
                    self?.update(market: market, orderbook: orderbook)
                } else {
                    self?.update(market: nil, orderbook: nil)
                }
            }
            .store(in: &subscriptions)
    }

    private func update(market: PerpetualMarket?, orderbook: MarketOrderbook?) {
        let tickSize = dydxFormatter.shared.format(decimal: orderbook?.grouping?.tickSize?.decimalValue)
        viewModel?.price = tickSize
        viewModel?.zoom = zoom(multiplier: orderbook?.grouping?.multiplier ?? OrderbookGrouping.none)
        viewModel?.onZoomed = { [weak self] zoom in
            if let self = self {
                AbacusStateManager.shared.setOrderbookMultiplier(multiplier: self.multiplier(zoom: zoom))
            }
        }
    }

    private func zoom(multiplier: OrderbookGrouping) -> UInt {
        switch multiplier {
        case OrderbookGrouping.none:
            return 0

        case OrderbookGrouping.x10:
            return 1

        case OrderbookGrouping.x100:
            return 2

        case OrderbookGrouping.x1000:
            return 3

        default:
            return 0
        }
    }

    private func multiplier(zoom: UInt) -> OrderbookGrouping {
        switch zoom {
        case 0:
            return OrderbookGrouping.none

        case 1:
            return OrderbookGrouping.x10

        case 2:
            return OrderbookGrouping.x100

        case 3:
            return OrderbookGrouping.x1000

        default:
            return OrderbookGrouping.x1000
        }
    }

}
