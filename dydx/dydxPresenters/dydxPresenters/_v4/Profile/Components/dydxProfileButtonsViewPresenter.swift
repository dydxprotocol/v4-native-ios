//
//  dydxProfileButtonsViewPresenter.swift
//  dydxPresenters
//
//  Created by Rui Huang on 2/7/23.
//

import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI
import dydxStateManager

protocol dydxProfileButtonsViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxProfileButtonsViewModel? { get }
}

class dydxProfileButtonsViewPresenter: HostedViewPresenter<dydxProfileButtonsViewModel>, dydxProfileButtonsViewPresenterProtocol {
    init(viewModel: dydxProfileButtonsViewModel) {
        super.init()

        self.viewModel = viewModel

        viewModel.depositAction = {
            Router.shared?.navigate(to: RoutingRequest(path: "/transfer", params: ["section": TransferSection.deposit.rawValue]), animated: true, completion: nil)
        }

        viewModel.withdrawAction = {
            Router.shared?.navigate(to: RoutingRequest(path: "/transfer", params: ["section": TransferSection.withdrawal.rawValue]), animated: true, completion: nil)
        }

        viewModel.transferAction = {
            Router.shared?.navigate(to: RoutingRequest(path: "/transfer", params: ["section": TransferSection.transferOut.rawValue]), animated: true, completion: nil)
        }

        viewModel.signOutAction = { [weak self] in
            guard let self = self else {
                return
            }
            AbacusStateManager.shared.state.walletState
                .map(\.currentWallet)
                .prefix(1)
                .sink { currentWallet in
                    let ethereumAddress = currentWallet?.ethereumAddress ?? ""
                    Router.shared?.navigate(to: RoutingRequest(path: "/action/wallet/disconnect", params: ["ethereumAddress": ethereumAddress]), animated: true, completion: nil)
                }
                .store(in: &self.subscriptions)
        }

        viewModel.onboardAction = {
            Router.shared?.navigate(to: RoutingRequest(path: "/onboard", params: nil), animated: true, completion: nil)
        }
    }

    override func start() {
        super.start()

        AbacusStateManager.shared.state.onboarded
            .sink { [weak self] onboarded in
                self?.viewModel?.onboarded = onboarded
            }
            .store(in: &subscriptions)
    }
}
