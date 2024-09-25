//
//  dydxMarketListViewPresenter.swift
//  dydxPresenters
//
//  Created by Rui Huang on 10/5/22.
//

import Utilities
import dydxViews
import dydxStateManager
import Combine
import Abacus

protocol dydxMarketListViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxMarketListViewModel? { get }
}

final class dydxMarketListViewPresenter: HostedViewPresenter<dydxMarketListViewModel>, dydxMarketListViewPresenterProtocol {
//    var selectedSortAction: AnyPublisher<SortAction?, Never>?
//    var selectedFilterAction: AnyPublisher<FilterAction?, Never>?

    private let favoriteStore = dydxFavoriteStore()

    override init() {
        super.init()

        viewModel = .init()
    }

    override func start() {
        super.start()

//        guard let selectedSortAction = selectedSortAction, let selectedFilterAction = selectedFilterAction else {
//            assertionFailure("No selectedSortAction or selectedFilterAction")
//            return
//        }
//
//        let actionPublisher: AnyPublisher<(SortAction?, FilterAction?)?, Never> =
//            Publishers
//                .CombineLatest(selectedSortAction,
//                               selectedFilterAction)
//                .compactMap { ($0, $1) }
//                .eraseToAnyPublisher()

        Publishers
            .CombineLatest(AbacusStateManager.shared.state.marketList,
                            AbacusStateManager.shared.state.assetMap)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] markets, assetMap in
                self?.updateAssetList(markets: markets, assetMap: assetMap)
            }
            .store(in: &subscriptions)
    }

    private func updateAssetList(markets: [PerpetualMarket], assetMap: [String: Asset]) {
        let markets = markets.filter { $0.status?.canTrade == true }
        viewModel?.markets = markets.map { market in
            let asset = assetMap[market.assetId]
            let market = dydxMarketViewModel(symbol: market.assetId,
                                             iconUrl: asset?.resources?.imageUrl,
                                             volume24H: market.perpetual?.volume24H?.doubleValue ?? 0,
                                             sparkline: market.perpetual?.line?.map(\.doubleValue) ?? [],
                                             price: market.oraclePrice?.doubleValue ?? 0,
                                             change: market.priceChange24HPercent?.doubleValue ?? 0)
            return market
        }
        .compactMap { $0 }

//        viewModel?.items = markets.compactMap { (market: PerpetualMarket) -> dydxMarketAssetItemViewModel in
//            allAssetIds.insert(market.assetId)
//
//            let vm = viewModelMap[market.id] ?? dydxMarketAssetItemViewModel()
//            viewModelMap[market.id] = vm
//
//            let asset = assetMap[market.assetId]
//            let viewModel = SharedMarketPresenter.createViewModel(market: market, asset: asset)
//            if viewModel != vm.sharedMarketViewModel {
//                vm.sharedMarketViewModel = viewModel
//                if market.priceChange24HPercent?.doubleValue ?? 0 > 0 {
//                    vm.gradientType = .plus
//                } else if market.priceChange24HPercent?.doubleValue ?? 0 < 0 {
//                    vm.gradientType = .minus
//                } else {
//                    vm.gradientType = .none
//                }
//            }
//
//            vm.onTap = {
//                Router.shared?.navigate(to: RoutingRequest(path: "/market", params: ["market": market.id]), animated: true, completion: nil)
//            }
//
//             vm.onFavoriteTap = {
//                vm.favoriteViewModel?.onTapped?()
//            }
//
//            // Reuse existing chart presenters
//            let chartPresenter: dydxAssetItemChartViewPresenter
//
//            if let p = chartPresenterMap[market.assetId] {
//                chartPresenter = p
//           } else {
//                chartPresenter = dydxAssetItemChartViewPresenter()
//                chartPresenter.start()
//                chartPresenterMap[market.assetId] = chartPresenter
//            }
//
//            if candlesMap[market.id] != chartPresenter.candles {
//                chartPresenter.candles = candlesMap[market.id]
//            }
//            chartPresenter.sparklines = market.perpetual?.line?.map(\.doubleValue)
//            if chartPresenter.priceChange24HPercent != market.priceChange24HPercent?.doubleValue {
//                chartPresenter.priceChange24HPercent = market.priceChange24HPercent?.doubleValue
//            }
//            chartPresenter.$viewModel.assign(to: &vm.$chartViewModel)
//
//            let favoritePresenter: dydxUserFavoriteViewPresenter
//            if let p = favoritePresenterMap[market.assetId] {
//                favoritePresenter = p
//            } else {
//                favoritePresenter = dydxUserFavoriteViewPresenter(handleTap: false)
//                favoritePresenter.marketId = market.id
//                favoritePresenter.start()
//                favoritePresenterMap[market.assetId] = favoritePresenter
//            }
//
//            var publisher = vm.$favoriteViewModel
//            favoritePresenter.$viewModel.assign(to: &publisher)
//
//            var publisher2 = vm.$isFavorited
//            favoritePresenter.viewModel?.$isFavorited.assign(to: &publisher2)
//
//            return vm
//        }
//
//        for market in markets {
//            if allAssetIds.contains(market.assetId) == false {
//                chartPresenterMap[market.assetId]?.stop()
//                chartPresenterMap.removeValue(forKey: market.assetId)
//            }
//        }
    }
}
