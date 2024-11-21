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

        AbacusStateManager.shared.setHistoricalTradingRewardPeriod(period: HistoricalTradingRewardsPeriod.weekly)
    }

    public override func start() {
        super.start()

        AbacusStateManager.shared.state.account
            .sink { [weak self] account in
                if let amount = account?.tradingRewards?.total?.doubleValue {
                    self?.viewModel?.allTimeRewardsAmount = dydxFormatter.shared.raw(number: NSNumber(value: amount), digits: 4)
                }
                if let amount = account?.tradingRewards?.filledHistory?["WEEKLY"]?.first?.amount {
                    self?.viewModel?.last7DaysRewardsAmount = dydxFormatter.shared.raw(number: NSNumber(value: amount), digits: 4)
                }
            }
            .store(in: &subscriptions)
    }
}
