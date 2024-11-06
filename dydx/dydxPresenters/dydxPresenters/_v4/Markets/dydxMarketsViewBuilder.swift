//
//  dydxMarketsViewBuilder.swift
//  dydxPresenters
//
//  Created by Rui Huang on 9/1/22.
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
import DGCharts
import dydxFormatter

public class dydxMarketsViewBuilder: NSObject, ObjectBuilderProtocol {
    public func build<T>() -> T? {
        let presenter = dydxMarketsViewPresenter()
        let view = presenter.viewModel?.createView() ?? PlatformViewModel().createView()
        return dydxMarketsViewController(presenter: presenter, view: view,
                                         configuration: .tabbarItemView) as? T
    }
}

private class dydxMarketsViewController: HostingViewController<PlatformView, dydxMarketsViewModel> {
    override public func arrive(to request: RoutingRequest?, animated: Bool) -> Bool {
        request?.path == "/portfolio/overview" || request?.path == "/markets"
    }
}

private class dydxMarketsViewPresenter: HostedViewPresenter<dydxMarketsViewModel> {
    @Published private var selectedSortAction: SortAction = SortAction.actions.first!
    @Published private var selectedFilterAction: FilterAction = FilterAction.actions.first!

    override init() {
        super.init()

        let viewModel = dydxMarketsViewModel()
        self.viewModel = viewModel

        viewModel.header = dydxMarketsHeaderViewModel(searchAction: {
            Router.shared?.navigate(to: RoutingRequest(path: "/markets/search"), animated: true, completion: nil)
        })

        // TODO: remove after election day
        // logic here turns this banner display off after election day
        // Nov 6 12am ET https://currentmillis.com/?1730869200010
        let electionDate = Date(timeIntervalSince1970: 1730869200)
        if Date.now <= electionDate && dydxBoolFeatureFlag.showPredictionMarketsUI.isEnabled {
            viewModel.banner = dydxMarketsBannerViewModel(navigationAction: {
                Router.shared?.navigate(to: RoutingRequest(path: "/trade/TRUMPWIN-USD"), animated: true, completion: nil)
            })
        }

        viewModel.summary = dydxMarketSummaryViewModel()
        viewModel.filter = dydxMarketAssetFilterViewModel(contents: FilterAction.actions.map(\.content),
                                                           onSelectionChanged: { [weak self] selectedIdx in
            self?.selectedFilterAction = FilterAction.actions[selectedIdx]
            if FilterAction.actions[selectedIdx].type == .predictionMarkets {
                self?.viewModel?.filterFooterText = DataLocalizer.localize(path: "APP.PREDICTION_MARKET.PREDICTION_MARKETS_SETTLEMENT_DESCRIPTION")
            } else {
                self?.viewModel?.filterFooterText = nil
            }
        })
        viewModel.sort = dydxMarketAssetSortViewModel(contents: SortAction.actions.map(\.text)) { [weak self] selectedIdx in
            self?.selectedSortAction = SortAction.actions[selectedIdx]
        }

        viewModel.marketsListViewModel?.onTap = { marketViewModel in
            Router.shared?.navigate(to: RoutingRequest(path: "/trade/\(marketViewModel.marketId)"), animated: true, completion: nil)
        }

        viewModel.marketsListViewModel?.onFavoriteTap = { marketViewModel in
            dydxFavoriteStore.shared.toggleFavorite(marketId: marketViewModel.marketId)
            marketViewModel.isFavorite = dydxFavoriteStore.shared.isFavorite(marketId: marketViewModel.marketId)
            // send this notification, otherwise, the favorite change has to bubble up to the marketsListViewModel which is slower. Adding this signal accelerates the propagation
            viewModel.marketsListViewModel?.objectWillChange.send()
        }
    }

    override func start() {
        super.start()

        AbacusStateManager.shared.state.marketSummary
            .sink { [weak self] (marketSummary: PerpetualMarketSummary) in
                self?.updateSummary(marketSummary: marketSummary)
            }
            .store(in: &subscriptions)

        Publishers
            .CombineLatest4(AbacusStateManager.shared.state.marketList,
                            AbacusStateManager.shared.state.assetMap,
                            $selectedSortAction,
                            $selectedFilterAction
            )
            .receive(on: DispatchQueue.main)
            .sink { [weak self] markets, assetMap, sort, filter in
                self?.updateAssetList(markets: markets, assetMap: assetMap, sort: sort, filter: filter)
            }
            .store(in: &subscriptions)

        Publishers
            .CombineLatest($selectedFilterAction, $selectedSortAction)
            .removeDuplicates(by: { $0.0 == $1.0 && $0.1 == $1.1 })
            .sink { [weak self] _, _ in
                self?.viewModel?.scrollAction = .toTop
            }
            .store(in: &subscriptions)
    }

    private func scrollToFirstAsset() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.viewModel?.scrollAction = .toTop
        }
    }

    private func updateAssetList(markets: [PerpetualMarket], assetMap: [String: Asset], sort: SortAction?, filter: FilterAction?) {
        let markets = markets.filter { $0.status?.canTrade == true }
        viewModel?.marketsListViewModel?.markets = markets
            .filter { filter?.action($0, assetMap) ?? true }
            .sorted { sort?.action($0, $1) ?? false }
            .map { market in
                let asset = assetMap[market.assetId]
                let market = dydxMarketViewModel(marketId: market.id,
                                                 assetId: asset?.displayableAssetId ?? market.assetId,
                                                 iconUrl: asset?.resources?.imageUrl,
                                                 volume24H: market.perpetual?.volume24H?.doubleValue ?? 0,
                                                 sparkline: market.perpetual?.line?.map(\.doubleValue) ?? [],
                                                 price: market.oraclePrice?.doubleValue ?? 0,
                                                 change: market.priceChange24HPercent?.doubleValue ?? 0,
                                                 isFavorite: dydxFavoriteStore.shared.isFavorite(marketId: market.id)
                )
                return market
            }
            .compactMap { $0 }
    }

    private func updateSummary(marketSummary: PerpetualMarketSummary) {
        let items = [
            dydxMarketSummaryViewModel.SummaryItem(header: DataLocalizer.localize(path: "APP.TRADE.VOLUME_24H"),
                                                   value: dydxFormatter.shared.dollarVolume(number: marketSummary.volume24HUSDC?.doubleValue) ?? ""),
            dydxMarketSummaryViewModel.SummaryItem(header: DataLocalizer.localize(path: "APP.TRADE.OPEN_INTEREST"),
                                                   value: dydxFormatter.shared.dollarVolume(number: marketSummary.openInterestUSDC?.doubleValue) ?? ""),
            dydxMarketSummaryViewModel.SummaryItem(header: DataLocalizer.localize(path: "APP.TRADE.TRADES"),
                                                   value: dydxFormatter.shared.localFormatted(number: marketSummary.trades24H?.doubleValue, size: "0") ?? "")
        ]
        if items != viewModel?.summary.items {
            viewModel?.summary.items = items
        }
    }
}
