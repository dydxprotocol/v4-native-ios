//
//  dydxTradingRewardsViewPresenter.swift
//  dydxPresenters
//
//  Created by Michael Maguire on 12/4/23.
//

import Utilities
import dydxViews
import RoutingKit
import PlatformUI

public class dydxTradingRewardsViewBuilder: NSObject, ObjectBuilderProtocol {
    public func build<T>() -> T? {
        let presenter = dydxTradingRewardsViewPresenter()
        let view = presenter.viewModel?.createView() ?? PlatformViewModel().createView()
        return dydxTradingRewardsViewController(presenter: presenter, view: view, configuration: .tabbarItemView) as? T
    }
}

private class dydxTradingRewardsViewController: HostingViewController<PlatformView, dydxTradingRewardsViewModel> {
    override public func arrive(to request: RoutingRequest?, animated: Bool) -> Bool {
        if request?.path == "/trading-rewards" {
            return true
        }
        return false
    }
}

private protocol dydxTradingRewardsViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxTradingRewardsViewModel? { get }
}

private class dydxTradingRewardsViewPresenter: HostedViewPresenter<dydxTradingRewardsViewModel>, dydxTradingRewardsViewPresenterProtocol {

    private let helpPresenter = dydxRewardsHelpViewPresenter()
    private let historyPresenter = dydxRewardsHistoryViewPresenter()

    override init() {
        super.init()

        let viewModel = dydxTradingRewardsViewModel()

        viewModel.headerViewModel.title = DataLocalizer.localize(path: "APP.GENERAL.TRADING_REWARDS")
        viewModel.headerViewModel.backButtonAction = {
            Router.shared?.navigate(to: RoutingRequest(path: "/action/dismiss"), animated: true, completion: nil)
        }

        helpPresenter.$viewModel.assign(to: &viewModel.$help)
        historyPresenter.$viewModel.assign(to: &viewModel.$history)

        self.viewModel = viewModel
    }
}
