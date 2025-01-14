//
//  dydxSimpleUIPositionListViewPresenter.swift
//  dydxPresenters
//
//  Created by Rui Huang on 13/01/2025.
//

import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI
import dydxStateManager
import Abacus
import Combine
import dydxFormatter

protocol dydxSimpleUIPositionListViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxSimpleUIPositionListViewModel? { get }
}

class dydxSimpleUIPositionListViewPresenter: HostedViewPresenter<dydxSimpleUIPositionListViewModel>, dydxSimpleUIPositionListViewPresenterProtocol {
    override init() {
        super.init()

        viewModel = dydxSimpleUIPositionListViewModel()
    }

    override func start() {
        super.start()

        Publishers
            .CombineLatest3(AbacusStateManager.shared.state.marketList,
                            AbacusStateManager.shared.state.assetMap,
                            AbacusStateManager.shared.state.selectedSubaccountPositions
            )
           .sink { [weak self] markets, assetMap, positions in
               self?.updateMarketList(markets: markets, assetMap: assetMap, positions: positions)
            }
            .store(in: &subscriptions)
    }

    private func updateMarketList(markets: [PerpetualMarket],
                                  assetMap: [String: Asset],
                                  positions: [SubaccountPosition]) {
        let markets = markets.filter { $0.status?.canTrade == true }
        viewModel?.positions = markets
            .compactMap { market in
                guard let asset = assetMap[market.assetId] else {
                    return nil
                }
                let position = positions.first { position in
                    position.id == market.id
                }
                if position == nil {
                    return nil
                }
                return dydxSimpleUIMarketViewModel.createFrom(market: market, asset: asset, position: position)
            }
            .sorted { lhs, rhs in
                return (lhs.positionTotal ?? 0) > (rhs.positionTotal ?? 0)
            }
    }
}
