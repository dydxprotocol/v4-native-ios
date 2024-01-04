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

        // TODO: get from abacus
        viewModel.launchIncentivesViewModel.seasonOrdinal = "--"
        viewModel.launchIncentivesViewModel.estimatedPoints = "--"
        viewModel.launchIncentivesViewModel.points = "--"
        viewModel.launchIncentivesViewModel.aboutAction = {
            Router.shared?.navigate(to: URL(string: "https://dydx.exchange/blog/v4-full-trading"), completion: nil)
        }
        viewModel.launchIncentivesViewModel.leaderboardAction = {
            Router.shared?.navigate(to: URL(string: "https://community.chaoslabs.xyz/dydx-v4/risk/leaderboard"), completion: nil)
        }

        // comment out as part of https://linear.app/dydx/issue/TRCL-3445/remove-governance-and-staking-cards
        // non-zero chance we add back
        // these vars and their corresponding files can be fully deleted if rewards is no longer relevant
//        viewModel.governanceViewModel = .init(
//            title: DataLocalizer.shared?.localize(path: "APP.GENERAL.GOVERNANCE", params: nil) ?? "",
//            description: DataLocalizer.shared?.localize(path: "APP.GENERAL.GOVERNANCE_DESCRIPTION", params: nil) ?? "") {
                // TODO: configure in env json
//                Router.shared?.navigate (to: , completion: nil)
//            }

//        viewModel.stakingViewModel = .init(
//            title: DataLocalizer.shared?.localize(path: "APP.GENERAL.STAKING", params: nil) ?? "",
//            description: DataLocalizer.shared?.localize(path: "APP.GENERAL.STAKING_DESCRIPTION", params: nil) ?? "") {
                // TODO: configure in env json
//                Router.shared?.navigate (to: , completion: nil)
//            }

        helpPresenter.$viewModel.assign(to: &viewModel.$help)
        historyPresenter.$viewModel.assign(to: &viewModel.$history)

        historyPresenter.viewModel?.contentChanged = { [weak self] in
            self?.viewModel?.objectWillChange.send()
        }

        self.viewModel = viewModel
    }
}
