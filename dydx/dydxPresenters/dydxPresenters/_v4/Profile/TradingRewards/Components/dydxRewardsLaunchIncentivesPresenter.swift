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

public protocol dydxRewardsLaunchIncentivesPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxRewardsLaunchIncentivesViewModel? { get }
}

public class dydxRewardsLaunchIncentivesPresenter: HostedViewPresenter<dydxRewardsLaunchIncentivesViewModel>, dydxRewardsLaunchIncentivesPresenterProtocol {

    override init() {
        super.init()

        viewModel = dydxRewardsLaunchIncentivesViewModel()
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
        
        

        viewModel.aboutAction = {
            Router.shared?.navigate(to: URL(string: "https://dydx.exchange/blog/v4-full-trading"), completion: nil)
        }
        
        viewModel.leaderboardAction = {
            Router.shared?.navigate(to: URL(string: "https://community.chaoslabs.xyz/dydx-v4/risk/leaderboard"), completion: nil)
        }
    }

    private func update(currentSeason: String?, seasonPointMap: [String: LaunchIncentivePoint]?) {
        viewModel?.seasonOrdinal = currentSeason
        if let currentSeason, let points = seasonPointMap?[currentSeason] {
            viewModel?.estimatedPoints = "\(points)"
            viewModel?.points = "\(points)"
        } else {
            viewModel?.estimatedPoints = nil
            viewModel?.points = nil
        }
    }
}
