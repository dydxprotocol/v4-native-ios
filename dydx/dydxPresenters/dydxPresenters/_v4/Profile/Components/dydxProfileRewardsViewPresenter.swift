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
        viewModel?.last7DaysRewardsAmount = "PLACEHOLDER"
        viewModel?.allTimeRewardsAmount = "PLACEHOLDER"

        viewModel?.tapAction = {
            Router.shared?.navigate(to: RoutingRequest(path: "/profile/trading-rewards"), animated: true, completion: nil)
        }
    }

    public override func start() {
        super.start()

        AbacusStateManager.shared.state.account
            .sink { [weak self] account in
                self?.viewModel?.allTimeRewardsAmount = dydxFormatter.shared.format(decimal: account?.tradingRewards?.total?.decimalValue)
                self?.viewModel?.last7DaysRewardsAmount = dydxFormatter.shared.format(number: account?.tradingRewards?.historical?["WEEKLY"]?.first?.amount)
            }
            .store(in: &subscriptions)
    }
}
