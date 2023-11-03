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

        viewModel.settingsAction = {
            Router.shared?.navigate(to: RoutingRequest(path: "/settings"), animated: true, completion: nil)
        }

        viewModel.helpAction = {
            let request = RoutingRequest(path: "/help")
            Router.shared?.navigate(to: request, animated: true, completion: nil)
        }

        viewModel.walletAction = { [weak self] in
            guard let self = self else {
                return
            }
            AbacusStateManager.shared.state.walletState
                .prefix(1)
                .sink { walletState in
                    if walletState.wallets.count > 0 {
                        Router.shared?.navigate(to: RoutingRequest(path: "/wallets"), animated: true, completion: nil)
                    } else {
                        Router.shared?.navigate(to: RoutingRequest(path: "/onboard/wallets"), animated: true, completion: nil)
                    }
                }
                .store(in: &self.subscriptions)
        }

        viewModel.signOutAction = { [weak self] in
            guard let self = self else {
                return
            }
            AbacusStateManager.shared.state.walletState
                .map(\.currentWallet)
                .prefix(1)
                .sink { currentWallet in
                    if let ethereumAddress = currentWallet?.ethereumAddress {
                        Router.shared?.navigate(to: RoutingRequest(path: "/action/wallet/disconnect", params: ["ethereumAddress": ethereumAddress]), animated: true, completion: nil)
                    }
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

        AbacusStateManager.shared.state.currentWallet
            .sink { [weak self] wallet in
                self?.viewModel?.walletImageUrl = wallet?.imageUrl
            }
            .store(in: &subscriptions)
    }
}
