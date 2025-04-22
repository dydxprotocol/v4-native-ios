//
//  dydxSimpleUIMarketSearchViewBuilder.swift
//  dydxPresenters
//
//  Created by Rui Huang on 15/01/2025.
//

import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI
import PlatformRouting
import FloatingPanel

public class dydxSimpleUIMarketSearchViewBuilder: NSObject, ObjectBuilderProtocol {
    public func build<T>() -> T? {
        let presenter = dydxSimpleUIMarketSearchViewPresenter()
        let view = presenter.viewModel?.createView() ?? PlatformViewModel().createView()
        return dydxSimpleUIMarketSearchViewController(presenter: presenter, view: view, configuration: .fullScreenSheet) as? T
    }
}

class dydxSimpleUIMarketSearchViewController: HostingViewController<PlatformView, dydxSimpleUIMarketSearchViewModel> {
    override public func arrive(to request: RoutingRequest?, animated: Bool) -> Bool {
        if request?.path == "/markets/search" {

            return true
        }
        return false
    }
}

private protocol dydxSimpleUIMarketSearchViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxSimpleUIMarketSearchViewModel? { get }
}

private class dydxSimpleUIMarketSearchViewPresenter: HostedViewPresenter<dydxSimpleUIMarketSearchViewModel>, dydxSimpleUIMarketSearchViewPresenterProtocol {

    private let marketListPresenter = dydxSimpleUIMarketListViewPresenter(excludePositions: false)
    private let sortPresenter = dydxSimpleUIMarketSortViewPresenter()

    private lazy var childPresenters: [HostedViewPresenterProtocol] = [
        marketListPresenter,
        sortPresenter
    ]

    override init() {
        let viewModel = dydxSimpleUIMarketSearchViewModel()

        marketListPresenter.$viewModel.assign(to: &viewModel.$marketList)
        sortPresenter.$viewModel.assign(to: &viewModel.$marketSort)

        super.init()

        self.viewModel = viewModel
        viewModel.onTextChanged = { [weak self] text in
            self?.marketListPresenter.searchText = text
            self?.viewModel?.searchText = text
            self?.updateShowCount()
        }

        marketListPresenter.onMarketSelected = { [weak self] marketId in
           self?.navigate(to: RoutingRequest(path: "/action/dismiss"), animated: true) { _, _ in
                self?.navigate(to: RoutingRequest(path: "/market", params: ["market": marketId]), animated: true, completion: nil)
            }
        }

        let actions = FilterAction.simpleUIActions
        viewModel.filter = dydxMarketAssetFilterViewModel(contents: actions.map(\.content),
                                                          onSelectionChanged: { [weak self] selectedIdx in
            self?.marketListPresenter.filterAction = actions[selectedIdx]
            self?.viewModel?.scrollAction = .toTop
            self?.updateShowCount()
        })

        attachChildren(workers: childPresenters)
    }

    override func start() {
        super.start()

        SimpleUIMarketSortOptionState.shared.$current
            .sink { [weak self] _ in
                self?.viewModel?.scrollAction = .toTop
            }
            .store(in: &subscriptions)
    }

    private func updateShowCount() {
        viewModel?.showCount = marketListPresenter.searchText.isNotEmpty || marketListPresenter.filterAction != .defaultAction
    }
}
