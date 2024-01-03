//
//  dydxProfileRewardsViewPresenter.swift
//  dydxPresenters
//
//  Created by Rui Huang on 9/18/23.
//

import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI
import Abacus
import dydxStateManager
import dydxFormatter
import Combine

public protocol dydxProfileRewardsViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxProfileRewardsViewModel? { get }
}

public class dydxProfileRewardsViewPresenter: HostedViewPresenter<dydxProfileRewardsViewModel>, dydxProfileRewardsViewPresenterProtocol {
    override init() {
        super.init()

        viewModel = dydxProfileRewardsViewModel()

        viewModel?.tapAction = {
            Router.shared?.navigate(to: RoutingRequest(path: "/profile/trading-rewards"), animated: true, completion: nil)
        }
    }

    public override func start() {
        super.start()

        AbacusStateManager.shared.state.account
            .sink { [weak self] account in
                // allTimeRewardsAmount is commented out because at time of writing, we do not have historical data accurate for "all time"
                // see thread: https://dydx-team.slack.com/archives/C066T2L1HM4/p1703107669507409
//                self?.viewModel?.allTimeRewardsAmount = dydxFormatter.shared.format(decimal: account?.tradingRewards?.total?.decimalValue)
                self?.viewModel?.last7DaysRewardsAmount = dydxFormatter.shared.format(number: account?.tradingRewards?.historical?["WEEKLY"]?.first?.amount)
            }
            .store(in: &subscriptions)
    }
}
