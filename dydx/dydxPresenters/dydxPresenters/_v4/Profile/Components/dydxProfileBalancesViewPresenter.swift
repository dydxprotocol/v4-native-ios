//
//  dydxProfileBalancesViewPresenter.swift
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

public protocol dydxProfileBalancesViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxProfileBalancesViewModel? { get }
}

public class dydxProfileBalancesViewPresenter: HostedViewPresenter<dydxProfileBalancesViewModel>, dydxProfileBalancesViewPresenterProtocol {
    override init() {
        super.init()

        viewModel = dydxProfileBalancesViewModel()
        viewModel?.nativeTokenName = dydxTokenConstants.nativeTokenName
        viewModel?.nativeTokenLogoUrl = dydxTokenConstants.nativeTokenLogoUrl
    }

    public override func start() {
        super.start()

        let decimal = 4
        let dydxTokenDenom = AbacusStateManager.shared.environment?.dydxTokenInfo?.denom
        Publishers
            .CombineLatest(
                AbacusStateManager.shared.state.accountBalance(of: dydxTokenDenom),
                AbacusStateManager.shared.state.stakingBalance(of: dydxTokenDenom)
            )
            .sink { [weak self] accountBalance, stakingBalance in
                if let accountBalance = accountBalance {
                    self?.viewModel?.walletAmount = dydxFormatter.shared.raw(number: Parser.standard.asNumber(accountBalance), digits: decimal)
                    self?.viewModel?.transferAction = {
                        Router.shared?.navigate(to: RoutingRequest(path: "/transfer", params: ["section": "transferOut"]), animated: true, completion: nil)
                    }
                } else {
                    self?.viewModel?.walletAmount = "-"
                    self?.viewModel?.transferAction = nil
                }

                if let stakingBalance = stakingBalance {
                    self?.viewModel?.stakedAmount = dydxFormatter.shared.raw(number: Parser.standard.asNumber(stakingBalance), digits: decimal)
                } else {
                    self?.viewModel?.stakedAmount = "-"
                }

                if accountBalance != nil || stakingBalance != nil {
                    let totalAmount = (accountBalance ?? 0.0) + (stakingBalance ?? 0.0)
                    self?.viewModel?.totalAmount = dydxFormatter.shared.raw(number: Parser.standard.asNumber(totalAmount), digits: decimal)
                } else {
                    self?.viewModel?.totalAmount = "-"
                }
            }
            .store(in: &subscriptions)
    }
}
