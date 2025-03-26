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
import dydxFormatter

private var cachedPresenter: dydxMarketsSearchViewPresenter?

public class dydxMarketsSearchViewBuilder: NSObject, ObjectBuilderProtocol {
    public func build<T>() -> T? {
        if dydxBoolFeatureFlag.simple_ui.isEnabled, AppMode.current == .simple {
            let viewController: dydxSimpleUIMarketSearchViewController? = dydxSimpleUIMarketSearchViewBuilder().build()
            return viewController as? T
        } else {
            let presenter = cachedPresenter ?? dydxMarketsSearchViewPresenter()
            cachedPresenter = presenter
            let view = presenter.viewModel?.createView() ?? PlatformViewModel().createView()
            let configuration = HostingViewControllerConfiguration(fixedHeight: UIScreen.main.bounds.height)
            return dydxMarketsSearchViewController(presenter: presenter, view: view, configuration: configuration) as? T
        }
    }
}

private class dydxMarketsSearchViewController: HostingViewController<PlatformView, dydxMarketsSearchViewModel> {
    override public func arrive(to request: RoutingRequest?, animated: Bool) -> Bool {
        guard request?.path == "/markets/search" else { return false }
        if let presenter = presenter as? dydxMarketsSearchViewPresenter {
            presenter.shouldShowResultsForEmptySearch = parser.asBoolean(request?.params?["shouldShowResultsForEmptySearch"])?.boolValue ?? true
        }
        return true
    }
}

protocol dydxMarketsSearchViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxMarketsSearchViewModel? { get }
}

private class dydxMarketsSearchViewPresenter: HostedViewPresenter<dydxMarketsSearchViewModel>, dydxMarketsSearchViewPresenterProtocol {
    fileprivate var shouldShowResultsForEmptySearch: Bool = false

    override init() {
        super.init()

        let viewModel = dydxMarketsSearchViewModel()
        viewModel.cancelAction = {
            Router.shared?.navigate(to: RoutingRequest(path: "/action/dismiss"), animated: true, completion: nil)
        }
        viewModel.marketsListViewModel?.onTap = { marketViewModel in
            Router.shared?.navigate(to: RoutingRequest(path: "/action/dismiss"), animated: true) { _, _ in
                Router.shared?.navigate(to: RoutingRequest(path: "/trade", params: ["market": marketViewModel.marketId]), animated: true, completion: nil)
            }
        }

        self.viewModel = viewModel
    }

    override func start() {
        super.start()

        guard let searchTextPublisher = viewModel?.$searchText.map({ $0.lowercased() }) else {
            return
        }

        Publishers
            .CombineLatest3(AbacusStateManager.shared.state.marketList,
                            AbacusStateManager.shared.state.assetMap,
                            searchTextPublisher.removeDuplicates())
            .sink { [weak self] (markets: [PerpetualMarket], assetMap: [String: Asset], searchText: String) in
                var filterMarkets = markets.filter { market in
                    guard market.status?.canTrade == true,
                        searchText.isNotEmpty || self?.shouldShowResultsForEmptySearch == true,
                        let asset = assetMap[market.assetId] else {
                        return false
                    }
                    return asset.displayableAssetId.lowercased().starts(with: searchText) ||
                        asset.name?.lowercased().starts(with: searchText) ?? false
                }
                // sort by volume if showing empty search string results and search text is empty
                if searchText.isEmpty && self?.shouldShowResultsForEmptySearch == true {
                    filterMarkets.sort { ($0.perpetual?.volume24H?.doubleValue ?? 0) > $1.perpetual?.volume24H?.doubleValue  ?? 0 }
                }
                self?.updateAssetList(markets: filterMarkets, assetMap: assetMap)
            }
            .store(in: &subscriptions)
    }

    private func updateAssetList(markets: [PerpetualMarket], assetMap: [String: Asset]) {
        viewModel?.marketsListViewModel?.markets = markets.compactMap { (market: PerpetualMarket) -> dydxMarketViewModel in
            let asset = assetMap[market.assetId]
            return dydxMarketViewModel.createFrom(market: market, asset: asset)
        }
    }
}
