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
    @Published var filterAction: FilterAction = .defaultAction

    var onMarketSelected: ((String) -> Void)?

    private var launchableMarkets: [dydxSimpleUIMarketViewModel]?

    init(excludePositions: Bool = true) {
        self.excludePositions = excludePositions
        super.init()

        viewModel = dydxSimpleUIMarketListViewModel()
    }

    override func start() {
        super.start()

        let modifiersPublisher =
            Publishers
                .CombineLatest3(
                    $searchText.map({ $0.lowercased() }).removeDuplicates(),
                    SimpleUIMarketSortOptionState.shared.$current,
                    $filterAction)
                .map { ($0, $1, $2) }
                .eraseToAnyPublisher()

        Publishers
            .CombineLatest4(AbacusStateManager.shared.state.marketList,
                            AbacusStateManager.shared.state.assetMap,
                            AbacusStateManager.shared.state.selectedSubaccountPositions,
                            modifiersPublisher
            )
           .sink { [weak self] markets, assetMap, positions, modifiers in
               self?.updateMarketList(markets: markets, assetMap: assetMap, positions: positions, searchText: modifiers.0, sortOption: modifiers.1, filterOption: modifiers.2)
            }
            .store(in: &subscriptions)
    }

    private var lastSearchText: String?
    private var lastSortOption: SimpleUIMarketSortOption?

    private func updateMarketList(markets: [PerpetualMarket],
                                  assetMap: [String: Asset],
                                  positions: [SubaccountPosition],
                                  searchText: String?,
                                  sortOption: SimpleUIMarketSortOption,
                                  filterOption: FilterAction) {
        let launchedMarkets: [dydxSimpleUIMarketViewModel]? = markets
            .filter { market in
                guard market.status?.canTrade == true, let asset = assetMap[market.assetId] else {
                    return false
                }
                if let searchText = searchText, searchText.isNotEmpty,
                   asset.displayableAssetId.lowercased().contains(searchText) == false,
                   asset.name?.lowercased().contains(searchText) == false {
                    return false
                }
                let position = positions.first { position in
                    position.id == market.id
                }
                if excludePositions && (position?.size.current?.doubleValue ?? 0.0) != 0.0 {
                    return false
                }

                // filter by favorite
                if sortOption == .favorites {
                    return FilterAction.favoriteAction.action(market, assetMap)
                }

                return filterOption.action(market, assetMap)
            }
            .sorted { (lhs: PerpetualMarket, rhs: PerpetualMarket) in
                switch sortOption {
                case .volume:
                    return (lhs.perpetual?.volume24H?.doubleValue ?? 0) > (rhs.perpetual?.volume24H?.doubleValue ?? 0)
                case .price:
                    return (lhs.oraclePrice?.doubleValue ?? 0) > (rhs.oraclePrice?.doubleValue ?? 0)
                case .gainers:
                    return (lhs.priceChange24HPercent?.doubleValue ?? 0) > (rhs.priceChange24HPercent?.doubleValue ?? 0)
                case .losers:
                    return (lhs.priceChange24HPercent?.doubleValue ?? 0) < (rhs.priceChange24HPercent?.doubleValue ?? 0)
                case .favorites:
                    return (lhs.perpetual?.volume24H?.doubleValue ?? 0) > (rhs.perpetual?.volume24H?.doubleValue ?? 0)
                }
            }
            .compactMap { market in
                guard let asset = assetMap[market.assetId] else {
                    return nil
                }
                let position = positions.first { position in
                    position.id == market.id
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

        if lastSearchText != searchText || launchableMarkets.isNilOrEmpty || lastSortOption != sortOption {
            lastSearchText = searchText
            lastSortOption = sortOption
            launchableMarkets = markets
                .filter { market in
                    guard market.isLaunched == false, let asset = assetMap[market.assetId] else {
                        return false
                    }
                    if let searchText = searchText, searchText.isNotEmpty,
                       asset.displayableAssetId.lowercased().contains(searchText) == false,
                       asset.name?.lowercased().contains(searchText) == false {
                        return false
                    }
                    return true
                }
                .sorted { (lhs: PerpetualMarket, rhs: PerpetualMarket) in
                    switch sortOption {
                    case .volume:
                        return (lhs.spot24hVolume?.doubleValue ?? 0) > (rhs.spot24hVolume?.doubleValue ?? 0)
                    case .price:
                        return (lhs.oraclePrice?.doubleValue ?? 0) > (rhs.oraclePrice?.doubleValue ?? 0)
                    case .gainers:
                        return (lhs.priceChange24HPercent?.doubleValue ?? 0) > (rhs.priceChange24HPercent?.doubleValue ?? 0)
                    case .losers:
                        return (lhs.priceChange24HPercent?.doubleValue ?? 0) < (rhs.priceChange24HPercent?.doubleValue ?? 0)
                    case .favorites:
                        return  (lhs.marketCaps ?? 0) > (rhs.marketCaps ?? 0)
                    }
                }
                .compactMap { market in
                    guard let asset = assetMap[market.assetId] else {
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
