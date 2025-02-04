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

    private lazy var childPresenters: [HostedViewPresenterProtocol] = [
        marketListPresenter
    ]

    override init() {
        let viewModel = dydxSimpleUIMarketSearchViewModel()

        marketListPresenter.$viewModel.assign(to: &viewModel.$marketList)

        super.init()

        self.viewModel = viewModel
        viewModel.onTextChanged = { [weak self] text in
            self?.marketListPresenter.searchText = text
        }

        marketListPresenter.onMarketSelected = { [weak self] marketId in
           self?.navigate(to: RoutingRequest(path: "/action/dismiss"), animated: true) { _, _ in
                self?.navigate(to: RoutingRequest(path: "/market", params: ["market": marketId]), animated: true, completion: nil)
            }
        }

        attachChildren(workers: childPresenters)
    }
}
