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

    private let excludePositions: Bool

    @Published var searchText: String = ""

    var onMarketSelected: ((String) -> Void)?

    private var launchableMarkets: [dydxSimpleUIMarketViewModel]?

    init(excludePositions: Bool = true) {
        self.excludePositions = excludePositions
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
        let launchedMarkets: [dydxSimpleUIMarketViewModel]? = markets
            .filter { $0.status?.canTrade == true }
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
                if excludePositions && (position?.size.current?.doubleValue ?? 0.0) != 0.0 {
                    return nil
                }
                return dydxSimpleUIMarketViewModel.createFrom(
                    displayType: .market,
                    market: market,
                    asset: asset,
                    position: position,
                    onMarketSelected: { [weak self] in
                    self?.onMarketSelected?(market.id)
                },
                    onCancelAction: nil)
            }
            .sorted { lhs, rhs in
                let lhsLeverage = lhs.leverage ?? 0
                let rhsLeverage = rhs.leverage ?? 0
                if lhsLeverage != 0 && rhsLeverage != 0 {
                    return (lhs.volumn ?? 0) > (rhs.volumn ?? 0)
                } else if lhsLeverage != 0 {
                    return true
                } else if rhsLeverage != 0 {
                    return false
                }

                return (lhs.volumn ?? 0) > (rhs.volumn ?? 0)
            }

        if launchableMarkets == nil {
            launchableMarkets = markets
                .filter { $0.isLaunched == false }
                .compactMap { market in
                    guard let asset = assetMap[market.assetId] else {
                        return nil
                    }
                    if let searchText = searchText, searchText.isNotEmpty,
                       asset.displayableAssetId.lowercased().contains(searchText) == false,
                       asset.name?.lowercased().contains(searchText) == false {
                        return nil
                    }
                    return dydxSimpleUIMarketViewModel.createFrom(
                        displayType: .market,
                        market: market,
                        asset: asset,
                        position: nil,
                        onMarketSelected: { [weak self] in
                        self?.onMarketSelected?(market.id)
                    },
                        onCancelAction: nil)
                }
                .sorted { lhs, rhs in
                    (lhs.marketCaps ?? 0) > (rhs.marketCaps ?? 0)
                }
        }

        viewModel?.markets = (launchedMarkets ?? []) + (launchableMarkets ?? [])
    }
}

extension dydxSimpleUIMarketViewModel {
    static func createFrom(displayType: dydxSimpleUIMarketViewModel.DisplayType,
                           market: PerpetualMarket,
                           asset: Asset?,
                           position: SubaccountPosition?,
                           onMarketSelected: (() -> Void)?,
                           onCancelAction: (() -> Void)?) -> dydxSimpleUIMarketViewModel {
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

        let positionSize = dydxFormatter.shared.localFormatted(number: position?.size.current?.abs().doubleValue, digits: market.configs?.displayStepSizeDecimals?.intValue ?? 1)

        return dydxSimpleUIMarketViewModel(displayType: displayType,
                                           marketId: market.id,
                                           assetName: asset?.displayableAssetId ?? market.assetId,
                                           iconUrl: asset?.resources?.imageUrl,
                                           price: price,
                                           change: change,
                                           sideText: side,
                                           leverage: position?.leverage.current?.doubleValue,
                                           volumn: market.perpetual?.volume24H?.doubleValue,
                                           positionTotal: position?.notionalTotal.current?.doubleValue,
                                           positionSize: positionSize,
                                           marketCaps: market.marketCaps?.doubleValue,
                                           isLaunched: market.isLaunched,
                                           onMarketSelected: onMarketSelected,
                                           onCancelAction: onCancelAction)
    }
}
