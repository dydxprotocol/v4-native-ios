//
//  dydxMarketAssetListViewPresenter.swift
//  dydxPresenters
//
//  Created by Rui Huang on 10/5/22.
//

import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI
import Abacus
import dydxStateManager
import Combine
import dydxFormatter

// MARK: AssetList

protocol dydxMarketAssetListViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxMarketAssetListViewModel? { get }
    var selectedSortAction: AnyPublisher<SortAction?, Never>? { get set }
    var selectedFilterAction: AnyPublisher<FilterAction?, Never>? { get set }
}

final class dydxMarketAssetListViewPresenter: HostedViewPresenter<dydxMarketAssetListViewModel>, dydxMarketAssetListViewPresenterProtocol {
    var selectedSortAction: AnyPublisher<SortAction?, Never>?
    var selectedFilterAction: AnyPublisher<FilterAction?, Never>?

    private var chartPresenterMap = [String: dydxAssetItemChartViewPresenter]()
    private var favoritePresenterMap = [String: dydxUserFavoriteViewPresenter]()
    private var viewModelMap = [String: dydxMarketAssetItemViewModel]()
    private let favoriteStore = dydxFavoriteStore()

    override init() {
        super.init()

        viewModel = dydxMarketAssetListViewModel()
    }

    override func start() {
        super.start()

        guard let selectedSortAction = selectedSortAction, let selectedFilterAction = selectedFilterAction else {
            assertionFailure("No selectedSortAction or selectedFilterAction")
            return
        }

        let actionPublisher: AnyPublisher<(SortAction?, FilterAction?)?, Never> =
            Publishers
                .CombineLatest(selectedSortAction,
                               selectedFilterAction)
                .compactMap { ($0, $1) }
                .eraseToAnyPublisher()

        Publishers
            .CombineLatest4(AbacusStateManager.shared.state.marketList,
                            AbacusStateManager.shared.state.candlesMap,
                            AbacusStateManager.shared.state.assetMap,
                            actionPublisher)
            .sink { [weak self] markets, candlesMap, assetMap, actionPublisher in
                var sortedMarkets = markets.filter { $0.status?.canTrade == true }
                if let action = actionPublisher?.1?.action {
                    sortedMarkets = sortedMarkets.filter { market in
                        action(market, assetMap)
                    }
                }
                if let action = actionPublisher?.0?.action {
                    sortedMarkets.sort(by: action)
                }
                self?.updateAssetList(markets: sortedMarkets, candlesMap: candlesMap, assetMap: assetMap)
            }
            .store(in: &subscriptions)
    }

    override func stop() {
        super.stop()

        chartPresenterMap.values.forEach { presenter in
            presenter.stop()
        }
        chartPresenterMap = [:]

        favoritePresenterMap.values.forEach { presenter in
            presenter.stop()
        }
        favoritePresenterMap = [:]
    }

    private func updateAssetList(markets: [PerpetualMarket], candlesMap: [String: MarketCandles], assetMap: [String: Asset]) {
        var allAssetIds = Set<String>()

        viewModel?.items = markets.compactMap { (market: PerpetualMarket) -> dydxMarketAssetItemViewModel in
            allAssetIds.insert(market.assetId)

            let vm = viewModelMap[market.id] ?? dydxMarketAssetItemViewModel()
            viewModelMap[market.id] = vm

            let asset = assetMap[market.assetId]
            let viewModel = SharedMarketPresenter.createViewModel(market: market, asset: asset)
            if viewModel != vm.sharedMarketViewModel {
                vm.sharedMarketViewModel = viewModel
                if market.priceChange24HPercent?.doubleValue ?? 0 > 0 {
                    vm.gradientType = .plus
                } else if market.priceChange24HPercent?.doubleValue ?? 0 < 0 {
                    vm.gradientType = .minus
                } else {
                    vm.gradientType = .none
                }
            }

            vm.onTap = {
                Router.shared?.navigate(to: RoutingRequest(path: "/market", params: ["market": market.id]), animated: true, completion: nil)
            }

             vm.onFavoriteTap = {
                vm.favoriteViewModel?.onTapped?()
            }

            // Reuse existing chart presenters
            let chartPresenter: dydxAssetItemChartViewPresenter

            if let p = chartPresenterMap[market.assetId] {
                chartPresenter = p
           } else {
                chartPresenter = dydxAssetItemChartViewPresenter()
                chartPresenter.start()
                chartPresenterMap[market.assetId] = chartPresenter
            }

            if candlesMap[market.id] != chartPresenter.candles {
                chartPresenter.candles = candlesMap[market.id]
            }
            chartPresenter.sparklines = market.perpetual?.line?.map(\.doubleValue)
            if chartPresenter.priceChange24HPercent != market.priceChange24HPercent?.doubleValue {
                chartPresenter.priceChange24HPercent = market.priceChange24HPercent?.doubleValue
            }
            chartPresenter.$viewModel.assign(to: &vm.$chartViewModel)

            let favoritePresenter: dydxUserFavoriteViewPresenter
            if let p = favoritePresenterMap[market.assetId] {
                favoritePresenter = p
            } else {
                favoritePresenter = dydxUserFavoriteViewPresenter(handleTap: false)
                favoritePresenter.marketId = market.id
                favoritePresenter.start()
                favoritePresenterMap[market.assetId] = favoritePresenter
            }

            var publisher = vm.$favoriteViewModel
            favoritePresenter.$viewModel.assign(to: &publisher)

            var publisher2 = vm.$isFavorited
            favoritePresenter.viewModel?.$isFavorited.assign(to: &publisher2)

            return vm
        }

        for market in markets {
            if allAssetIds.contains(market.assetId) == false {
                chartPresenterMap[market.assetId]?.stop()
                chartPresenterMap.removeValue(forKey: market.assetId)
            }
        }
    }
}

// MARK: Sorting

struct SortAction: Equatable {
    static var defaultAction: SortAction {
        SortAction(type: .volume24h,
                   text: DataLocalizer.localize(path: "APP.TRADE.VOLUME"),
                   action: { first, second  in
                       first.perpetual?.volume24H?.doubleValue ?? 0 > second.perpetual?.volume24H?.doubleValue ?? 0
                   })
    }

    static var actions: [SortAction] {
        [
            .defaultAction,
            SortAction(type: .gainers,
                       text: DataLocalizer.localize(path: "APP.GENERAL.GAINERS"),
                       action: { first, second  in
                           first.priceChange24HPercent?.doubleValue ?? 0 > second.priceChange24HPercent?.doubleValue ?? 0
                       }),

            SortAction(type: .losers,
                       text: DataLocalizer.localize(path: "APP.GENERAL.LOSERS"),
                       action: { first, second  in
                           first.priceChange24HPercent?.doubleValue ?? 0 < second.priceChange24HPercent?.doubleValue ?? 0
                       }),

            SortAction(type: .fundingRate,
                       text: DataLocalizer.localize(path: "APP.GENERAL.FUNDING_RATE_CHART_SHORT"),
                       action: { first, second  in
                           first.perpetual?.nextFundingRate?.doubleValue ?? 0 > second.perpetual?.nextFundingRate?.doubleValue ?? 0
                       }),

            SortAction(type: .name,
                       text: DataLocalizer.localize(path: "APP.GENERAL.NAME"),
                       action: { first, second  in
                           first.market ?? "" < second.market ?? ""
                       }),

            SortAction(type: .price,
                       text: DataLocalizer.localize(path: "APP.GENERAL.PRICE"),
                       action: { first, second  in
                           first.oraclePrice?.doubleValue ?? 0 > second.oraclePrice?.doubleValue ?? 0
                       })
        ]
    }

    private let type: MarketSorting
    let text: String
    let action: ((PerpetualMarket, PerpetualMarket) -> Bool)

    static func == (lhs: SortAction, rhs: SortAction) -> Bool {
        lhs.type == rhs.type
    }
}

// MARK: Filter

struct FilterAction: Equatable {
    static var defaultAction: FilterAction {
        FilterAction(type: .all,
                     content: .text(DataLocalizer.localize(path: "APP.GENERAL.ALL")),
                     action: { _, _ in
                         true       // included
                     })
    }

    static var actions: [FilterAction] {
        var actions = [
            .defaultAction,

            FilterAction(type: .favorited,
                         content: .icon(UIImage.named("action_like_unselected", bundles: Bundle.particles) ?? UIImage()),
                         action: { market, _ in
                             dydxFavoriteStore().isFavorite(marketId: market.id)
                         }),

            FilterAction(type: .new,
                         content: .text(DataLocalizer.localize(path: "APP.GENERAL.RECENTLY_LISTED")),
                         action: { market, _ in
                             market.perpetual?.isNew ?? false
                         })
        ]
        if dydxBoolFeatureFlag.showPredictionMarketsUI.isEnabled {
            let predictionMarketText = DataLocalizer.localize(path: "APP.GENERAL.PREDICTION_MARKET")
            let newPillConfig = TabItemViewModel.TabItemContent.PillConfig(text: DataLocalizer.localize(path: "APP.GENERAL.NEW"),
                                                                           textColor: .colorPurple,
                                                                           backgroundColor: .colorFadedPurple)
            let content = TabItemViewModel.TabItemContent.textWithPillAccessory(text: predictionMarketText,
                                                                                pillConfig: newPillConfig)
            let predictionMarketsAction = FilterAction(type: .predictionMarkets,
                                                       content: content,
                                                       action: { market, assetMap in
                                                            assetMap[market.assetId]?.tags?.contains("Prediction Market") ?? false
                                                       })
            actions.append(predictionMarketsAction)
        }
        actions.append(contentsOf: [
            FilterAction(type: .layer1,
                         content: .text(DataLocalizer.localize(path: "APP.GENERAL.LAYER_1")),
                         action: { market, assetMap in
                         assetMap[market.assetId]?.tags?.contains("Layer 1") ?? false
                         }),

            FilterAction(type: .layer2,
                         content: .text(DataLocalizer.localize(path: "APP.GENERAL.LAYER_2")),
                         action: { market, assetMap in
                         assetMap[market.assetId]?.tags?.contains("Layer 2") ?? false
                         }),

            FilterAction(type: .defi,
                         content: .text(DataLocalizer.localize(path: "APP.GENERAL.DEFI")),
                         action: { market, assetMap in
                         assetMap[market.assetId]?.tags?.contains("Defi") ?? false
                         }),

            FilterAction(type: .ai,
                         content: .text(DataLocalizer.localize(path: "APP.GENERAL.AI")),
                         action: { market, assetMap in
                             if market.assetId == "RENDER" {
                                 print(assetMap[market.assetId]?.tags?.first ?? "aa")
                             }
                         return assetMap[market.assetId]?.tags?.contains("AI") ?? false
                         }),

            FilterAction(type: .nft,
                         content: .text(DataLocalizer.localize(path: "APP.GENERAL.NFT")),
                         action: { market, assetMap in
                         assetMap[market.assetId]?.tags?.contains("NFT") ?? false
                         }),

            FilterAction(type: .gaming,
                         content: .text(DataLocalizer.localize(path: "APP.GENERAL.GAMING")),
                         action: { market, assetMap in
                         assetMap[market.assetId]?.tags?.contains("Gaming") ?? false
                         }),

            FilterAction(type: .meme,
                         content: .text(DataLocalizer.localize(path: "APP.GENERAL.MEME")),
                         action: { market, assetMap in
                         assetMap[market.assetId]?.tags?.contains("Meme") ?? false
                         }),

            FilterAction(type: .rwa,
                         content: .text(DataLocalizer.localize(path: "APP.GENERAL.REAL_WORLD_ASSET_SHORT")),
                         action: { market, assetMap in
                         assetMap[market.assetId]?.tags?.contains("RWA") ?? false
                         }),

            FilterAction(type: .ent,
                         content: .text(DataLocalizer.localize(path: "APP.GENERAL.ENTERTAINMENT")),
                         action: { market, assetMap in
                         assetMap[market.assetId]?.tags?.contains("ENT") ?? false
                         })
        ])
        return actions
    }

    let type: MarketFiltering
    let content: TabItemViewModel.TabItemContent
    let action: ((PerpetualMarket, [String: Asset]) -> Bool)

    static func == (lhs: FilterAction, rhs: FilterAction) -> Bool {
        lhs.type == rhs.type
    }
}

enum MarketSorting: Equatable {
    case name
    case marketCap
    case volume24h
    case change24h
    case openInterest
    case fundingRate
    case price
    case gainers
    case losers
}

enum MarketFiltering: Equatable {
    case all
    case favorited
    case predictionMarkets
    case layer1
    case layer2
    case defi
    case new
    case ai
    case nft
    case gaming
    case meme
    case rwa
    case ent
}
