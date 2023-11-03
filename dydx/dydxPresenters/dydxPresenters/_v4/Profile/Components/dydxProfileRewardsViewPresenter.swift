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
        viewModel?.nativeTokenName = dydxTokenConstants.nativeTokenName
        viewModel?.nativeTokenLogoUrl = dydxTokenConstants.nativeTokenLogoUrl
    }

    public override func start() {
        super.start()

        AbacusStateManager.shared.state.accountBalance(of: .dydx)
            .sink { [weak self] dydxAmount in
                if let dydxAmount = dydxAmount {
                    self?.viewModel?.walletAmount = dydxFormatter.shared.raw(number: Parser.standard.asNumber(dydxAmount), digits: 4)
                    self?.viewModel?.transferAction = {
                        Router.shared?.navigate(to: RoutingRequest(path: "/transfer", params: ["section": "transferOut"]), animated: true, completion: nil)
                    }
                } else {
                    self?.viewModel?.walletAmount = "-"
                    self?.viewModel?.transferAction = nil
                }
            }
            .store(in: &subscriptions)

        AbacusStateManager.shared.state.stakingBalance(of: .dydx)
            .sink { [weak self] dydxAmount in
                if let dydxAmount = dydxAmount {
                    self?.viewModel?.stakedAmount = dydxFormatter.shared.raw(number: Parser.standard.asNumber(dydxAmount), digits: 4)
                } else {
                    self?.viewModel?.stakedAmount = "-"
                }
            }
            .store(in: &subscriptions)
    }
}
