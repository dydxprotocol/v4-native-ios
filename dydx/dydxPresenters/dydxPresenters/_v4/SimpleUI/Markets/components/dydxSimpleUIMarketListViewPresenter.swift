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
    @Published var favUpdated = 0

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
                .CombineLatest4(
                    $searchText.map({ $0.lowercased() }).removeDuplicates(),
                    SimpleUIMarketSortOptionState.shared.$current,
                    $filterAction,
                    $favUpdated)
                .map { ($0, $1, $2, $3) }
                .eraseToAnyPublisher()

        Publishers
            .CombineLatest4(AbacusStateManager.shared.state.marketList,
                            AbacusStateManager.shared.state.assetMap,
                            AbacusStateManager.shared.state.selectedSubaccount,
                            modifiersPublisher
            )
           .sink { [weak self] markets, assetMap, subaccount, modifiers in
               self?.updateMarketList(markets: markets,
                                      assetMap: assetMap,
                                      subaccount: subaccount,
                                      searchText: modifiers.0,
                                      sortOption: modifiers.1,
                                      filterOption: modifiers.2,
                                      favUpdated: modifiers.3)
            }
            .store(in: &subscriptions)
    }

    // Keeping those states so that we don't update the launchable list unless it's necessary
    // for performance consideration
    private var lastSearchText: String?
    private var lastSortOption: SimpleUIMarketSortOption?
    private var lastFilterOption: FilterAction?
    private var lastFavUpdated: Int?

    private func updateMarketList(markets: [PerpetualMarket],
                                  assetMap: [String: Asset],
                                  subaccount: Subaccount?,
                                  searchText: String?,
                                  sortOption: SimpleUIMarketSortOption,
                                  filterOption: FilterAction,
                                  favUpdated: Int) {
        let launchedMarkets = createLaunchedMarkets(markets: markets,
                                                    assetMap: assetMap,
                                                    subaccount: subaccount,
                                                    searchText: searchText,
                                                    sortOption: sortOption,
                                                    filterOption: filterOption,
                                                    favUpdated: favUpdated)

        if lastSearchText != searchText || launchableMarkets.isNilOrEmpty || lastSortOption != sortOption || lastFilterOption != filterOption || lastFavUpdated != favUpdated {
            lastSearchText = searchText
            lastSortOption = sortOption
            lastFilterOption = filterOption
            lastFavUpdated = favUpdated

            launchableMarkets = createLaunchableMarkets(markets: markets,
                                                        assetMap: assetMap,
                                                        subaccount: subaccount,
                                                        searchText: searchText,
                                                        sortOption: sortOption,
                                                        filterOption: filterOption,
                                                        favUpdated: favUpdated)
        }
        viewModel?.markets = (launchedMarkets ?? []) + (launchableMarkets ?? [])
    }

    private func createLaunchedMarkets(markets: [PerpetualMarket],
                                       assetMap: [String: Asset],
                                       subaccount: Subaccount?,
                                       searchText: String?,
                                       sortOption: SimpleUIMarketSortOption,
                                       filterOption: FilterAction,
                                       favUpdated: Int) -> [dydxSimpleUIMarketViewModel]? {
        let positions = subaccount?.openPositions ?? []
        return markets
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
                if sortOption == .favorites, FilterAction.favoriteAction.action(market, assetMap) == false {
                    return false
                }

                return filterOption.action(market, assetMap)
            }
            .sorted { (lhs: PerpetualMarket, rhs: PerpetualMarket) in
                switch sortOption {
                case .marketCap:
                    return (lhs.marketCaps?.doubleValue ?? 0) > (rhs.marketCaps?.doubleValue ?? 0)
                case .volume:
                    return (lhs.perpetual?.volume24H?.doubleValue ?? 0) > (rhs.perpetual?.volume24H?.doubleValue ?? 0)
                case .price:
                    return (lhs.oraclePrice?.doubleValue ?? 0) > (rhs.oraclePrice?.doubleValue ?? 0)
                case .gainers:
                    return (lhs.priceChange24HPercent?.doubleValue ?? 0) > (rhs.priceChange24HPercent?.doubleValue ?? 0)
                case .losers:
                    return (lhs.priceChange24HPercent?.doubleValue ?? 0) < (rhs.priceChange24HPercent?.doubleValue ?? 0)
                case .favorites:
                    return (lhs.marketCaps?.doubleValue ?? 0) > (rhs.marketCaps?.doubleValue ?? 0)
                }
            }
            .compactMap { market in
                guard let asset = assetMap[market.assetId] else {
                    return nil
                }
                let position = positions.first { position in
                    position.id == market.id
                }
                let isFavorite = dydxFavoriteStore.shared.isFavorite(marketId: market.id)
                return dydxSimpleUIMarketViewModel.createFrom(
                    displayType: .market,
                    market: market,
                    asset: asset,
                    subaccount: subaccount,
                    position: position,
                    isFavorite: isFavorite,
                    positionToggleOption: nil,
                    onMarketSelected: { [weak self] in
                        self?.onMarketSelected?(market.id)
                    },
                    onCancelAction: nil,
                    onFavoriteTapped: { [weak self] in
                        dydxFavoriteStore.shared.toggleFavorite(marketId: market.id)
                        self?.favUpdated += 1
                    })
            }
    }

    private func createLaunchableMarkets(markets: [PerpetualMarket],
                                         assetMap: [String: Asset],
                                         subaccount: Subaccount?,
                                         searchText: String?,
                                         sortOption: SimpleUIMarketSortOption,
                                         filterOption: FilterAction,
                                         favUpdated: Int) -> [dydxSimpleUIMarketViewModel]? {
        return markets
            .filter { market in
                guard market.isLaunched == false, let asset = assetMap[market.assetId] else {
                    return false
                }
                if let searchText = searchText, searchText.isNotEmpty,
                   asset.displayableAssetId.lowercased().contains(searchText) == false,
                   asset.name?.lowercased().contains(searchText) == false {
                    return false
                }

                // filter by favorite
                if sortOption == .favorites, FilterAction.favoriteAction.action(market, assetMap) == false {
                    return false
                }

                return filterOption.action(market, assetMap)
            }
            .sorted { (lhs: PerpetualMarket, rhs: PerpetualMarket) in
                switch sortOption {
                case .marketCap:
                    return (lhs.marketCaps?.doubleValue ?? 0) > (rhs.marketCaps?.doubleValue ?? 0)
                case .volume:
                    return (lhs.spot24hVolume?.doubleValue ?? 0) > (rhs.spot24hVolume?.doubleValue ?? 0)
                case .price:
                    return (lhs.oraclePrice?.doubleValue ?? 0) > (rhs.oraclePrice?.doubleValue ?? 0)
                case .gainers:
                    return (lhs.priceChange24HPercent?.doubleValue ?? 0) > (rhs.priceChange24HPercent?.doubleValue ?? 0)
                case .losers:
                    return (lhs.priceChange24HPercent?.doubleValue ?? 0) < (rhs.priceChange24HPercent?.doubleValue ?? 0)
                case .favorites:
                    return  (lhs.marketCaps?.doubleValue ?? 0) > (rhs.marketCaps?.doubleValue ?? 0)
                }
            }
            .compactMap { market in
                guard let asset = assetMap[market.assetId] else {
                    return nil
                }
                let isFavorite = dydxFavoriteStore.shared.isFavorite(marketId: market.id)
                return dydxSimpleUIMarketViewModel.createFrom(
                    displayType: .market,
                    market: market,
                    asset: asset,
                    subaccount: subaccount,
                    position: nil,
                    isFavorite: isFavorite,
                    positionToggleOption: nil,
                    onMarketSelected: { [weak self] in
                        self?.onMarketSelected?(market.id)
                    },
                    onCancelAction: nil,
                    onFavoriteTapped: { [weak self] in
                        dydxFavoriteStore.shared.toggleFavorite(marketId: market.id)
                        self?.favUpdated += 1
                    })
            }
    }
}

extension dydxSimpleUIMarketViewModel {
    static func createFrom(displayType: dydxSimpleUIMarketViewModel.DisplayType,
                           market: PerpetualMarket,
                           asset: Asset?,
                           subaccount: Subaccount?,
                           position: SubaccountPosition?,
                           isFavorite: Bool,
                           positionToggleOption: SimpleUIPositionToggleOption?,
                           onMarketSelected: (() -> Void)?,
                           onCancelAction: (() -> Void)?,
                           onFavoriteTapped: (() -> Void)?) -> dydxSimpleUIMarketViewModel {
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

        let amount = position?.unrealizedPnl.current?.doubleValue ?? 0
        let amountText = dydxFormatter.shared.dollar(number: abs(amount), digits: 2) ?? ""
        let percent = position?.unrealizedPnlPercent.current?.doubleValue ?? 0
        let percentText = dydxFormatter.shared.percent(number: abs(percent), digits: 2) ?? ""
        let unrealizedPnl = SignedAmountViewModel(text: "\(amountText) (\(percentText))",
                                                  sign: .init(value: amount),
                                                  coloringOption: .allText)

        let marginValueText = dydxFormatter.shared.dollar(number: position?.marginValue.current?.doubleValue ?? 0, digits: 2) ?? ""

        let marginUsage: MarginUsageModel?
        switch position?.marginMode {
        case .cross:
            marginUsage = MarginUsageModel(percent: subaccount?.marginUsage?.current?.doubleValue ?? 0)
        case .isolated:
            marginUsage = MarginUsageModel(percent: position?.marginUsage.current?.doubleValue ?? 0)
        default:
            marginUsage = nil
        }

        return dydxSimpleUIMarketViewModel(displayType: displayType,
                                           positionToggleType: positionToggleOption?.viewOption ?? .pnl,
                                           marketId: market.id,
                                           assetName: asset?.displayableAssetId ?? market.assetId,
                                           iconUrl: asset?.resources?.imageUrl,
                                           price: price,
                                           change: change,
                                           unrealizedPNLAmount: unrealizedPnl,
                                           marginValue: marginValueText,
                                           marginUsage: marginUsage,
                                           sideText: side,
                                           leverage: abs(position?.leverage.current?.doubleValue ?? 0),
                                           volumn: market.perpetual?.volume24H?.doubleValue,
                                           positionTotal: position?.notionalTotal.current?.doubleValue,
                                           positionSize: positionSize,
                                           marketCaps: market.marketCaps?.doubleValue,
                                           isLaunched: market.isLaunched,
                                           isFavorite: isFavorite,
                                           onMarketSelected: onMarketSelected,
                                           onCancelAction: onCancelAction,
                                           onFavoriteTapped: onFavoriteTapped)
    }
}
