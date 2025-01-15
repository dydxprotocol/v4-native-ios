//
//  dydxSimpleUIMarketsViewBuilder.swift
//  dydxPresenters
//
//  Created by Rui Huang on 17/12/2024.
//

import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI
import dydxStateManager
import Abacus

public class dydxSimpleUIMarketsViewBuilder: NSObject, ObjectBuilderProtocol {
    public func build<T>() -> T? {
        let presenter = dydxSimpleUIMarketsViewPresenter()
        let view = presenter.viewModel?.createView() ?? PlatformViewModel().createView()
        return dydxSimpleUIMarketsViewController(presenter: presenter, view: view, configuration: .default) as? T
    }
}

public class dydxSimpleUIMarketsViewController: HostingViewController<PlatformView, dydxSimpleUIMarketsViewModel> {
    override public func arrive(to request: RoutingRequest?, animated: Bool) -> Bool {
        if request?.path == "/" {
            return true
        }
        return false
    }
}

public protocol dydxSimpleUIMarketsViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxSimpleUIMarketsViewModel? { get }
}

public class dydxSimpleUIMarketsViewPresenter: HostedViewPresenter<dydxSimpleUIMarketsViewModel>, dydxSimpleUIMarketsViewPresenterProtocol {

    private let marketListPresenter = dydxSimpleUIMarketListViewPresenter(excludePositions: true)
    private let positionListPresenter = dydxSimpleUIPositionListViewPresenter()
    private let portfolioPresenter = dydxSimpleUIPortfolioViewPresenter()
    private let headerPresenter = dydxSimpleUIMarketsHeaderViewPresenter()

    private lazy var childPresenters: [HostedViewPresenterProtocol] = [
        marketListPresenter,
        positionListPresenter,
        portfolioPresenter,
        headerPresenter
    ]

    override init() {
        let viewModel = dydxSimpleUIMarketsViewModel()

        marketListPresenter.$viewModel.assign(to: &viewModel.$marketList)
        positionListPresenter.$viewModel.assign(to: &viewModel.$positionList)
        portfolioPresenter.$viewModel.assign(to: &viewModel.$portfolio)
        headerPresenter.$viewModel.assign(to: &viewModel.$header)

        super.init()

        self.viewModel = viewModel

        viewModel.searchAction = {
            Router.shared?.navigate(to: RoutingRequest(path: "/markets/search"),
                                    animated: true,
                                    completion: nil)
        }

        marketListPresenter.onMarketSelected = { marketId in
            Router.shared?.navigate(to: RoutingRequest(path: "/market", params: ["market": marketId]), animated: true, completion: nil)
        }

        attachChildren(workers: childPresenters)
    }

    public override func start() {
        super.start()

        positionListPresenter.viewModel?.$positions
            .sink { [weak self] positions in
                self?.viewModel?.hasPosition = positions.isNilOrEmpty == false
            }
            .store(in: &subscriptions)
    }
}
