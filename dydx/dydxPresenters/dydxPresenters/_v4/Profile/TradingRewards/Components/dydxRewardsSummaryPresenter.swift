//
//  dydxRewardsSummaryPresenter.swift
//  dydxPresenters
//
//  Created by Michael Maguire on 12/4/23.
//

import dydxViews
import PlatformParticles
import ParticlesKit
import Combine
import dydxStateManager
import dydxFormatter

public protocol dydxRewardsSummaryPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxProfileRewardsViewModel? { get }
}

public class dydxRewardsSummaryViewPresenter: HostedViewPresenter<dydxProfileRewardsViewModel>, dydxProfileRewardsViewPresenterProtocol {
    override init() {
        super.init()

        viewModel = dydxProfileRewardsViewModel()
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
