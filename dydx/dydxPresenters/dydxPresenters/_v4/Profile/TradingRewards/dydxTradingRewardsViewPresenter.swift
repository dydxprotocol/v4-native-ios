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
import dydxStateManager
import dydxFormatter

public class dydxTradingRewardsViewBuilder: NSObject, ObjectBuilderProtocol {
    public func build<T>() -> T? {
        let presenter = dydxTradingRewardsViewPresenter()
        let view = presenter.viewModel?.createView() ?? PlatformViewModel().createView()
        return dydxTradingRewardsViewController(presenter: presenter, view: view, configuration: .tabbarItemView) as? T
    }
}

private class dydxTradingRewardsViewController: HostingViewController<PlatformView, dydxTradingRewardsViewModel> {
    override public func arrive(to request: RoutingRequest?, animated: Bool) -> Bool {
        if request?.path == "/profile/trading-rewards" {
            return true
        }
        return false
    }
}

private protocol dydxTradingRewardsViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxTradingRewardsViewModel? { get }
}

private class dydxTradingRewardsViewPresenter: HostedViewPresenter<dydxTradingRewardsViewModel>, dydxTradingRewardsViewPresenterProtocol {

    private let launchIncentivesPresenter = dydxRewardsLaunchIncentivesPresenter()
    private let summaryPresenter = dydxRewardsSummaryViewPresenter()
    private let helpPresenter = dydxRewardsHelpViewPresenter()
    private let historyPresenter = dydxRewardsHistoryViewPresenter()

    private lazy var childPresenters: [HostedViewPresenterProtocol] = [
        launchIncentivesPresenter,
        summaryPresenter,
        helpPresenter,
        historyPresenter
    ]

    override init() {

        let viewModel = dydxTradingRewardsViewModel()

        viewModel.headerViewModel.title = DataLocalizer.localize(path: "APP.GENERAL.TRADING_REWARDS")
        viewModel.headerViewModel.backButtonAction = {
            Router.shared?.navigate(to: RoutingRequest(path: "/action/dismiss"), animated: true, completion: nil)
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

        launchIncentivesPresenter.$viewModel.assign(to: &viewModel.$launchIncentivesViewModel)
        summaryPresenter.$viewModel.assign(to: &viewModel.$rewardsSummary)
        helpPresenter.$viewModel.assign(to: &viewModel.$help)
        historyPresenter.$viewModel.assign(to: &viewModel.$history)

        historyPresenter.viewModel?.contentChanged = { [weak viewModel] in
            viewModel?.objectWillChange.send()
        }

        super.init()

        self.viewModel = viewModel

        attachChildren(workers: childPresenters)
    }
}
