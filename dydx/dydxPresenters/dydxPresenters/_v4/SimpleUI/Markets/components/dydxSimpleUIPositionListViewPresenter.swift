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

    @Published var favUpdated = 0

    override init() {
        super.init()

        viewModel = dydxSimpleUIPositionListViewModel()
    }

    override func start() {
        super.start()

        let modifiersPublisher =
            Publishers
                .CombineLatest(
                    SimpleUIPositionToggleOptionState.shared.$current,
                    $favUpdated)
                .map { ($0, $1) }
                .eraseToAnyPublisher()

        Publishers
            .CombineLatest4(AbacusStateManager.shared.state.marketList,
                            AbacusStateManager.shared.state.assetMap,
                            AbacusStateManager.shared.state.selectedSubaccount,
                            modifiersPublisher
            )
           .sink { [weak self] markets, assetMap, subaccount, modifier in
               self?.updateMarketList(markets: markets,
                                      assetMap: assetMap,
                                      subaccount: subaccount,
                                      positionToggleOption: modifier.0)
            }
            .store(in: &subscriptions)
    }

    private func updateMarketList(markets: [PerpetualMarket],
                                  assetMap: [String: Asset],
                                  subaccount: Subaccount?,
                                  positionToggleOption: SimpleUIPositionToggleOption) {
        let positions = subaccount?.openPositions ?? []
        let markets = markets.filter { $0.status?.canTrade == true }
        viewModel?.positions = markets
            .compactMap { market in
                guard let asset = assetMap[market.assetId] else {
                    return nil
                }
                let position = positions.first { position in
                    position.id == market.id
                }
                if position == nil || (position?.size.current?.doubleValue ?? 0.0) == 0.0 {
                    return nil
                }
                let isFavorite = dydxFavoriteStore.shared.isFavorite(marketId: market.id)
                return dydxSimpleUIMarketViewModel.createFrom(
                    displayType: .position,
                    market: market,
                    asset: asset,
                    subaccount: subaccount,
                    position: position,
                    isFavorite: isFavorite,
                    positionToggleOption: positionToggleOption,
                    onMarketSelected: { [weak self] in
                        self?.navigate(to: RoutingRequest(path: "/market", params: ["market": market.id]), animated: true, completion: nil)
                    },
                    onCancelAction: { [weak self] in
                        if let marketId = position?.id {
                            self?.navigate(to: RoutingRequest(path: "/trade/simple/close",
                                                              params: ["marketId": marketId]),
                                           animated: true, completion: nil)
                        }
                    },
                    onFavoriteTapped: { [weak self] in
                        dydxFavoriteStore.shared.toggleFavorite(marketId: market.id)
                        self?.favUpdated += 1
                    }
                )
            }
            .sorted { lhs, rhs in
                return (lhs.positionTotal ?? 0) > (rhs.positionTotal ?? 0)
            }
    }
}
