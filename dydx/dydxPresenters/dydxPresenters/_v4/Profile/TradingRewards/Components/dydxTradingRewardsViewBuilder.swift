//
//  dydxRewardsSummaryPresenter.swift
//  dydxPresenters
//
//  Created by Michael Maguire on 12/4/23.
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

public protocol dydxRewardsSummaryPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxProfileRewardsViewModel? { get }
}

public class dydxRewardsSummaryViewPresenter: HostedViewPresenter<dydxProfileRewardsViewModel>, dydxProfileRewardsViewPresenterProtocol {
    override init() {
        super.init()

        viewModel = dydxProfileRewardsViewModel()
        viewModel?.last7DaysRewardsAmount = "PLACEHOLDER"
        viewModel?.allTimeRewardsAmount = "PLACEHOLDER"
    }
}
