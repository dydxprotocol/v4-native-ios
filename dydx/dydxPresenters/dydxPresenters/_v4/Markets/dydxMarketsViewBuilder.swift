//
//  dydxMarketsBuilder.swift
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
import Charts
import dydxFormatter
import dydxAnalytics

public class dydxMarketsViewBuilder: NSObject, ObjectBuilderProtocol {
    public func build<T>() -> T? {
        let assetListPresenter = dydxMarketAssetListViewPresenter()
        let presenter = dydxMarketsViewPresenter(assetListPresenter: assetListPresenter)
        let view = presenter.viewModel?.createView() ?? PlatformViewModel().createView()
        return dydxMarketsViewController(presenter: presenter, view: view,
                                         configuration: .tabbarItemView) as? T
    }
}

private class dydxMarketsViewController: HostingViewController<PlatformView, dydxMarketsViewModel> {

    override var navigationEvent: TrackableEvent? { AnalyticsEventV2.navigatePage(page: .markets) }

    override public func arrive(to request: RoutingRequest?, animated: Bool) -> Bool {
        request?.path == "/markets"
    }
}

private class dydxMarketsViewPresenter: HostedViewPresenter<dydxMarketsViewModel> {
    private var assetListPresenter: dydxMarketAssetListViewPresenterProtocol?

    @Published private var selectedSortAction: SortAction? = SortAction.actions.first
    @Published private var selectedFilterAction: FilterAction? = FilterAction.actions.first

    init(assetListPresenter: dydxMarketAssetListViewPresenterProtocol) {
        self.assetListPresenter = assetListPresenter
        super.init()

        viewModel = dydxMarketsViewModel()
        viewModel?.header = dydxMarketsHeaderViewModel(searchAction: {
            Router.shared?.navigate(to: RoutingRequest(path: "/markets/search"), animated: true, completion: nil)
        })
        viewModel?.summary = dydxMarketSummaryViewModel()
        viewModel?.filter = dydxMarketAssetFilterViewModel(contents: FilterAction.actions.map(\.content),
                                                           onSelectionChanged: { [weak self] selectedIdx in
            self?.selectedFilterAction = FilterAction.actions[selectedIdx]
        })
        viewModel?.sort = dydxMarketAssetSortViewModel(contents: SortAction.actions.map(\.text)) { [weak self] selectedIdx in
            self?.selectedSortAction = SortAction.actions[selectedIdx]
        }
        viewModel?.assetList = assetListPresenter.viewModel
        assetListPresenter.viewModel?.contentChanged = { [weak self] in
            self?.viewModel?.objectWillChange.send()
        }

        self.assetListPresenter?.selectedSortAction = $selectedSortAction.eraseToAnyPublisher()
        self.assetListPresenter?.selectedFilterAction = $selectedFilterAction.eraseToAnyPublisher()
    }

    override func start() {
        super.start()

        AbacusStateManager.shared.state.marketSummary
            .sink { [weak self] (marketSummary: PerpetualMarketSummary) in
                self?.updateSummary(marketSummary: marketSummary)
            }
            .store(in: &subscriptions)

        assetListPresenter?.start()

        $selectedFilterAction
            .removeDuplicates { lhs, rhs in
                lhs?.type == rhs?.type
            }
            .dropFirst()
            .sink { [weak self] _ in
                self?.scrollToFirstAsset()
            }
            .store(in: &subscriptions)

        $selectedSortAction
            .removeDuplicates { lhs, rhs in
                lhs?.type == rhs?.type
            }
            .dropFirst()
            .sink { [weak self] _ in
                self?.scrollToFirstAsset()
            }
            .store(in: &subscriptions)
    }

    override func stop() {
        super.stop()

        assetListPresenter?.stop()
    }

    private func scrollToFirstAsset() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.viewModel?.scrollAction = .toTop
        }
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
