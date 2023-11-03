//
//  dydxPortfolioHeaderPresenter.swift
//  dydxPresenters
//
//  Created by Rui Huang on 1/24/23.
//

import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI
import Abacus
import dydxStateManager
import Combine
import dydxFormatter

protocol dydxPortfolioHeaderPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxPortfolioHeaderViewModel? { get }
}

class dydxPortfolioHeaderPresenter: HostedViewPresenter<dydxPortfolioHeaderViewModel>, dydxPortfolioHeaderPresenterProtocol {
    init(viewModel: dydxPortfolioHeaderViewModel?) {
        super.init()

        self.viewModel = viewModel

        viewModel?.onboardAction = {
            Router.shared?.navigate(to: RoutingRequest(path: "/onboard"), animated: true, completion: { /* [weak self] */ _, _ in
            })
        }
        viewModel?.depositAction = {
            Router.shared?.navigate(to: RoutingRequest(path: "/transfer"), animated: true, completion: { /* [weak self] */ _, _ in
            })
        }
    }

    override func start() {
        super.start()

        AbacusStateManager.shared.state.onboarded
            .sink { [weak self] onboarded in
                if onboarded {
                    self?.viewModel?.state = .onboardCompleted
                } else {
                    self?.viewModel?.state = .onboard
                }
            }
            .store(in: &subscriptions)
    }
}
