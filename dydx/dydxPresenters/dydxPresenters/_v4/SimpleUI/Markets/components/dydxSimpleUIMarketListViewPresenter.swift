//
//  dydxSimpleUIMarketListViewPresenter.swift
//  dydxPresenters
//
//  Created by Rui Huang on 18/12/2024.
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

protocol dydxSimpleUIMarketListViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxSimpleUIMarketListViewModel? { get }
}

class dydxSimpleUIMarketListViewPresenter: HostedViewPresenter<dydxSimpleUIMarketListViewModel>, dydxSimpleUIMarketListViewPresenterProtocol {

    @Published var searchText: String = ""

    override init() {
        super.init()

        viewModel = dydxSimpleUIMarketListViewModel()
    }

    override func start() {
        super.start()

        let searchTextPublisher = $searchText.map({ $0.lowercased() }).removeDuplicates()

        Publishers
            .CombineLatest4(AbacusStateManager.shared.state.marketList,
                            AbacusStateManager.shared.state.assetMap,
                            AbacusStateManager.shared.state.selectedSubaccountPositions,
                            searchTextPublisher
            )
           .sink { [weak self] markets, assetMap, positions, searchText in
               self?.updateMarketList(markets: markets, assetMap: assetMap, positions: positions, searchText: searchText)
            }
            .store(in: &subscriptions)
    }

    private func updateMarketList(markets: [PerpetualMarket],
                                  assetMap: [String: Asset],
                                  positions: [SubaccountPosition],
                                  searchText: String?) {
        let markets = markets.filter { $0.status?.canTrade == true }
        viewModel?.markets = markets
            .compactMap { market in
                guard let asset = assetMap[market.assetId] else {
                    return nil
                }
                if let searchText = searchText, searchText.isNotEmpty,
                   asset.displayableAssetId.lowercased().contains(searchText) == false,
                   asset.name?.lowercased().contains(searchText) == false {
                    return nil
                }
                let position = positions.first { position in
                    position.id == market.id
                }
                return dydxSimpleUIMarketViewModel.createFrom(market: market, asset: asset, position: position)
            }
            .sorted { lhs, rhs in
                if lhs.leverage != nil && rhs.leverage != nil {
                    return (lhs.volumn ?? 0) > (rhs.volumn ?? 0)
                } else if lhs.leverage != nil {
                    return true
                } else if rhs.leverage != nil {
                    return false
                }
                return (lhs.volumn ?? 0) > (rhs.volumn ?? 0)
            }
    }
}

private extension dydxSimpleUIMarketViewModel {
    static func createFrom(market: PerpetualMarket, asset: Asset?, position: SubaccountPosition?) -> dydxSimpleUIMarketViewModel {
        let price = dydxFormatter.shared.dollar(number: market.oraclePrice?.doubleValue, digits: market.configs?.displayTickSizeDecimals?.intValue ?? 2)
        let change = SignedAmountViewModel(amount: market.priceChange24HPercent?.doubleValue,
                                           displayType: .percent,
                                           coloringOption: .allText)
        var side = SideTextViewModel(side: .custom(DataLocalizer.localize(path: "APP.GENERAL.NO_POSITION")))
        if let position = position {
            if position.side.current == Abacus.PositionSide.long_ {
                side = SideTextViewModel(side: .long)
            } else if position.side.current == Abacus.PositionSide.short_ {
                side = SideTextViewModel(side: .short)
            }
        }
        let leverage = dydxFormatter.shared.raw(number: position?.leverage.current?.doubleValue, digits: 3)
        return dydxSimpleUIMarketViewModel(marketId: market.id,
                                           assetName: asset?.displayableAssetId ?? market.assetId,
                                           iconUrl: asset?.resources?.imageUrl,
                                           price: price,
                                           change: change,
                                           sideText: side,
                                           leverage: leverage,
                                           volumn: market.perpetual?.volume24HUSDC?.doubleValue,
                                           onMarketSelected: {
        })
    }
}
