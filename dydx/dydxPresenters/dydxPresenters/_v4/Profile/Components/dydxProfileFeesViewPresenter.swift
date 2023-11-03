//
//  dydxProfileFeesViewPresenter.swift
//  dydxPresenters
//
//  Created by Rui Huang on 8/8/23.
//

import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI
import dydxStateManager
import Abacus
import dydxFormatter

protocol dydxProfileFeesViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxProfileFeesViewModel? { get }
}

class dydxProfileFeesViewPresenter: HostedViewPresenter<dydxProfileFeesViewModel>, dydxProfileFeesViewPresenterProtocol {
    override init() {
        super.init()

        viewModel = dydxProfileFeesViewModel()
        viewModel?.tapAction = {
            Router.shared?.navigate(to: RoutingRequest(path: "/profile/fees"), animated: true, completion: nil)
        }
    }

    override func start() {
        super.start()

        AbacusStateManager.shared.state.user
            .sink { [weak self] user in
                self?.updateFees(user: user)
            }
            .store(in: &subscriptions)
    }

    private func updateFees(user: User?) {
        guard let user = user else {
            viewModel?.tradingVolume = nil
            viewModel?.takerFeeRate = nil
            viewModel?.makerFeeRate = nil
            return
        }

        let volume30D = user.makerVolume30D + user.takerVolume30D
        viewModel?.tradingVolume = dydxFormatter.shared.dollarVolume(number: volume30D)
        viewModel?.takerFeeRate = dydxFormatter.shared.percent(number: abs(user.takerFeeRate), digits: 3)
        viewModel?.makerFeeRate = dydxFormatter.shared.percent(number: abs(user.makerFeeRate), digits: 3)
    }
}
