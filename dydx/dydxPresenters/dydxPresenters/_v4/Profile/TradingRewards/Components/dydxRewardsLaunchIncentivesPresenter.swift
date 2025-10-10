//
//  dydxRewardsLaunchIncentivesPresenter.swift
//  dydxPresenters
//
//  Created by Michael Maguire on 2/20/24.
//

import dydxViews
import PlatformParticles
import ParticlesKit
import Combine
import dydxStateManager
import dydxFormatter
import Utilities
import Abacus
import RoutingKit

public protocol dydxRewardsLaunchIncentivesPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxRewardsLaunchIncentivesViewModel? { get }
}

public class dydxRewardsLaunchIncentivesPresenter: HostedViewPresenter<dydxRewardsLaunchIncentivesViewModel>, dydxRewardsLaunchIncentivesPresenterProtocol {

    override init() {
        super.init()

        viewModel = dydxRewardsLaunchIncentivesViewModel()
        viewModel?.isSep2025 = dydxBoolFeatureFlag.rewards_sep_2025.isEnabled
        viewModel?.rewardsAmount = dydxRewardsParam.rewards_dollar_amount.string
        viewModel?.rewardsRebate = dydxRewardsParam.rewards_fee_rebate_percent.string
    }

    public override func start() {
        super.start()

        Publishers.CombineLatest(
            AbacusStateManager.shared.state.account,
            AbacusStateManager.shared.state.launchIncentive)
        .sink { [weak self] (account, launchIncentive) in
            self?.update(currentSeason: launchIncentive?.currentSeason, seasonPointMap: account?.launchIncentivePoints?.points)

        }
        .store(in: &subscriptions)

        viewModel?.aboutAction = {
            let urlString = AbacusStateManager.shared.environment?.links?.incentiveProgram
            if let urlString = urlString, let url = URL(string: urlString) {
                Router.shared?.navigate(to: url, completion: nil)
            }
        }

        viewModel?.leaderboardAction = {
            let urlString = AbacusStateManager.shared.environment?.links?.incentiveProgramLeaderboard
            if let urlString = urlString, let url = URL(string: urlString) {
                Router.shared?.navigate(to: url, completion: nil)
            }
        }
    }

    private func update(currentSeason: String?, seasonPointMap: [String: LaunchIncentivePoint]?) {
        viewModel?.seasonOrdinal = currentSeason
        if let currentSeason, let incentivePoints = seasonPointMap?[currentSeason]?.incentivePoints {
            viewModel?.points = "\(incentivePoints)"
        } else {
            viewModel?.points = "--"
        }
    }
}
