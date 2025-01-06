//
//  dydxSimpleUIMarketsHeaderViewPresenter.swift
//  dydxPresenters
//
//  Created by Rui Huang on 05/01/2025.
//

import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI
import dydxStateManager
import Abacus
import Combine
import dydxFormatter

protocol dydxSimpleUIMarketsHeaderViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxSimpleUIMarketsHeaderViewModel? { get }
}

class dydxSimpleUIMarketsHeaderViewPresenter: HostedViewPresenter<dydxSimpleUIMarketsHeaderViewModel>, dydxSimpleUIMarketsHeaderViewPresenterProtocol {
    override init() {
        super.init()

        viewModel = dydxSimpleUIMarketsHeaderViewModel()
    }

    override func start() {
        super.start()

        Publishers.CombineLatest(
            AbacusStateManager.shared.state.onboarded,
            AbacusStateManager.shared.state.walletState
        )
        .sink { [weak self] onboarded, walletState in
            guard let self = self else { return }
            self.update(onboarded: onboarded, currentWallet: walletState.currentWallet)
        }
        .store(in: &subscriptions)
    }

    private func update(onboarded: Bool, currentWallet: dydxWalletInstance?) {
        viewModel?.onboarded = onboarded

        let ethereumAddress = currentWallet?.ethereumAddress ?? ""
        if onboarded {
            viewModel?.items = [.transfers, .history, .settings, .help, .signOut(ethereumAddress: ethereumAddress)]
        } else {
            viewModel?.items = [.signIn, .settings, .help]
        }
    }
}

private extension dydxSimpleUIMarketsHeaderViewModel.MenuItem {

    static let signIn = dydxSimpleUIMarketsHeaderViewModel.MenuItem(
        icon: "icon_wallet_connect",
        title: DataLocalizer.localize(path: "APP.GENERAL.CONNECT_WALLET")) {
            Router.shared?.navigate(to: RoutingRequest(path: "/onboard/wallets"), animated: true, completion: nil)
        }

    static func signOut(ethereumAddress: String) -> Self {
        dydxSimpleUIMarketsHeaderViewModel.MenuItem(
            icon: "settings_signout",
            title: DataLocalizer.localize(path: "APP.GENERAL.SIGN_OUT")) {
                Router.shared?.navigate(to: RoutingRequest(path: "/action/wallet/disconnect", params: ["ethereumAddress": ethereumAddress]), animated: true, completion: nil)
            }
    }

    static let settings = dydxSimpleUIMarketsHeaderViewModel.MenuItem(
        icon: "icon_settings",
        title: DataLocalizer.localize(path: "APP.EMAIL_NOTIFICATIONS.SETTINGS")) {
            Router.shared?.navigate(to: RoutingRequest(url: "/settings"), animated: true, completion: nil)
        }

    static let history = dydxSimpleUIMarketsHeaderViewModel.MenuItem(
        icon: "icon_clock",
        title: DataLocalizer.localize(path: "APP.GENERAL.HISTORY")) {
            Router.shared?.navigate(to: RoutingRequest(path: "/portfolio/history"), animated: true, completion: nil)
        }

    static let transfers = dydxSimpleUIMarketsHeaderViewModel.MenuItem(
        icon: "icon_transfer",
        title: DataLocalizer.localize(path: "APP.GENERAL.TRANSFER")) {
            Router.shared?.navigate(to: RoutingRequest(path: "/transfer"), animated: true, completion: nil)
        }

    static let help = dydxSimpleUIMarketsHeaderViewModel.MenuItem(
        icon: "icon_help",
        title: DataLocalizer.localize(path: "APP.HEADER.HELP")) {
            Router.shared?.navigate(to: RoutingRequest(path: "/help"), animated: true, completion: nil)
        }
}
