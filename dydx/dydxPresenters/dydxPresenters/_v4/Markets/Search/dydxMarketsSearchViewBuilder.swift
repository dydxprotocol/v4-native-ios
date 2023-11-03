//
//  dydxMarketsSearchViewBuilder.swift
//  dydxPresenters
//
//  Created by Rui Huang on 10/4/22.
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

public class dydxMarketsSearchViewBuilder: NSObject, ObjectBuilderProtocol {
    public func build<T>() -> T? {
        let presenter = dydxMarketsSearchViewPresenter()
        let view = presenter.viewModel?.createView() ?? PlatformViewModel().createView()
        let configuration = HostingViewControllerConfiguration(fixedHeight: UIScreen.main.bounds.height)
        return dydxMarketsSearchViewController(presenter: presenter, view: view, configuration: configuration) as? T
    }
}

private class dydxMarketsSearchViewController: HostingViewController<PlatformView, dydxSearchViewModel> {
    override public func arrive(to request: RoutingRequest?, animated: Bool) -> Bool {
        request?.path == "/markets/search"
    }
}

private class dydxMarketsSearchViewPresenter: dydxSearchViewPresenter {
    private var chartPresenterMap = [String: dydxAssetItemChartViewPresenter]()

    override init() {
        super.init()
    }

    override func start() {
        super.start()

        guard let searchTextPublisher = viewModel?.$searchText else {
            return
        }

        Publishers
            .CombineLatest4(AbacusStateManager.shared.state.marketList,
                            AbacusStateManager.shared.state.candlesMap,
                            AbacusStateManager.shared.state.assetMap,
                            searchTextPublisher.removeDuplicates())
            .sink { [weak self] (markets: [PerpetualMarket], candlesMap: [String: MarketCandles], assetMap: [String: Asset], searchText: String?) in
                let filterMarkets = markets.filter { market in
                    guard market.status?.canTrade == true,
                            let searchText = searchText?.lowercased(), searchText.length > 0,
                            let asset = assetMap[market.assetId] else {
                        return false
                    }
                    return asset.id.lowercased().starts(with: searchText) ||
                        asset.name?.lowercased().starts(with: searchText) ?? false
                }
                self?.updateAssetList(markets: filterMarkets, candlesMap: candlesMap, assetMap: assetMap)
            }
            .store(in: &subscriptions)
    }

    override func stop() {
        super.stop()

        chartPresenterMap.values.forEach { presenter in
            presenter.stop()
        }
        chartPresenterMap = [:]
    }

    private func updateAssetList(markets: [PerpetualMarket], candlesMap: [String: MarketCandles], assetMap: [String: Asset]) {
        var allAssetIds = Set<String>()
        viewModel?.itemList?.items = markets.compactMap { (market: PerpetualMarket) -> dydxMarketAssetItemViewModel in
            allAssetIds.insert(market.assetId)

            let vm = dydxMarketAssetItemViewModel()

            let asset = assetMap[market.assetId]
            let viewModel = SharedMarketPresenter.createViewModel(market: market, asset: asset)
            if viewModel != vm.sharedMarketViewModel {
                vm.sharedMarketViewModel = viewModel
            }

            vm.onTap = {
                Router.shared?.navigate(to: RoutingRequest(path: "/action/dismiss"), animated: false) { _, _ in
                    Router.shared?.navigate(to: RoutingRequest(path: "/trade", params: ["market": market.id]), animated: true, completion: nil)
                }
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
            vm.chartViewModel = chartPresenter.viewModel

            return vm
        }

        for market in markets where allAssetIds.contains(market.assetId) == false {
            chartPresenterMap[market.assetId]?.stop()
            chartPresenterMap.removeValue(forKey: market.assetId)
        }
    }
}
