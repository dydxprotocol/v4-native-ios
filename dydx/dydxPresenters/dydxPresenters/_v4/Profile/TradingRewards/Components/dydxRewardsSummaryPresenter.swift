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
import Utilities

public protocol dydxRewardsSummaryPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxRewardsSummaryViewModel? { get }
}

public class dydxRewardsSummaryViewPresenter: HostedViewPresenter<dydxRewardsSummaryViewModel>, dydxRewardsSummaryPresenterProtocol {
    override init() {
        super.init()

        viewModel = dydxRewardsSummaryViewModel()
    }

    public override func start() {
        super.start()

        AbacusStateManager.shared.state.account
            .sink { [weak self] account in
                // allTimeRewardsAmount is commented out because we do not have historical data accurate for "all time"
                // see thread: https://dydx-team.slack.com/archives/C066T2L1HM4/p1703107669507409
                // self?.viewModel?.allTimeRewardsAmount = dydxFormatter.shared.format(decimal: account?.tradingRewards?.total?.decimalValue)
                if let thisWeekRewards = account?.tradingRewards?.historical?["WEEKLY"]?.first {
                    self?.viewModel?.last7DaysRewardsAmount = dydxFormatter.shared.raw(number: NSNumber(value: thisWeekRewards.amount), digits: 4)
                    let startedAt = dydxFormatter.shared.millisecondsToDate(thisWeekRewards.startedAtInMilliseconds, format: .MMM_d)
                    let endedAt = dydxFormatter.shared.millisecondsToDate(thisWeekRewards.endedAtInMilliseconds, format: .MMM_d)
                    self?.viewModel?.last7DaysRewardsPeriod = DataLocalizer.shared?.localize(path: "APP.GENERAL.TIME_STRINGS.PERIOD", params: ["START": startedAt, "END": endedAt])
                }
            }
            .store(in: &subscriptions)
    }
}
