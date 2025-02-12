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
            viewModel?.items = [transfers, alerts, history, settings, help, signOut(ethereumAddress: ethereumAddress), switchMode]
            viewModel?.depositAction = { [weak self] in
                self?.navigate(to: RoutingRequest(path: "/transfer", params: ["section": TransferSection.deposit.rawValue]), animated: true, completion: nil)
            }
//            viewModel?.withdrawAction = {
//                Router.shared?.navigate(to: RoutingRequest(path: "/transfer", params: ["section": TransferSection.withdrawal.rawValue]), animated: true, completion: nil)
//            }
        } else {
            viewModel?.items = [signIn, settings, help, switchMode]
            viewModel?.depositAction = nil
            viewModel?.withdrawAction = nil
        }
    }

    private var signIn: dydxSimpleUIMarketsHeaderViewModel.MenuItem { dydxSimpleUIMarketsHeaderViewModel.MenuItem(
        icon: "icon_wallet_connect",
        title: DataLocalizer.localize(path: "APP.GENERAL.CONNECT_WALLET")) { [weak self] in
            self?.navigate(to: RoutingRequest(path: "/onboard/wallets"), animated: true, completion: nil)
        }
    }

    private func signOut(ethereumAddress: String) -> dydxSimpleUIMarketsHeaderViewModel.MenuItem {
        dydxSimpleUIMarketsHeaderViewModel.MenuItem(
            icon: "icon_close",
            title: DataLocalizer.localize(path: "APP.GENERAL.SIGN_OUT"),
            destructive: true) { [weak self] in
                self?.navigate(to: RoutingRequest(path: "/action/wallet/disconnect", params: ["ethereumAddress": ethereumAddress]), animated: true, completion: nil)
            }
    }

    private var settings: dydxSimpleUIMarketsHeaderViewModel.MenuItem { dydxSimpleUIMarketsHeaderViewModel.MenuItem(
            icon: "icon_settings_1",
            title: DataLocalizer.localize(path: "APP.EMAIL_NOTIFICATIONS.SETTINGS")) { [weak self] in
                self?.navigate(to: RoutingRequest(url: "/settings"), animated: true, completion: nil)
        }
    }

    private var alerts: dydxSimpleUIMarketsHeaderViewModel.MenuItem { dydxSimpleUIMarketsHeaderViewModel.MenuItem(
            icon: "icon_alerts_circle",
            title: DataLocalizer.localize(path: "APP.GENERAL.ALERTS")) { [weak self] in
                self?.navigate(to: RoutingRequest(url: "/alerts"), animated: true, completion: nil)
        }
    }

    private var history: dydxSimpleUIMarketsHeaderViewModel.MenuItem {
        dydxSimpleUIMarketsHeaderViewModel.MenuItem(
            icon: "icon_history",
            title: DataLocalizer.localize(path: "APP.GENERAL.HISTORY")) { [weak self] in
                self?.navigate(to: RoutingRequest(path: "/portfolio/history",
                                                  params: ["inTabBar": "false"]),
                               animated: true, completion: nil)
            }
    }

    private var transfers: dydxSimpleUIMarketsHeaderViewModel.MenuItem { dydxSimpleUIMarketsHeaderViewModel.MenuItem(
        icon: "icon_transfer",
        title: DataLocalizer.localize(path: "APP.GENERAL.TRANSFER")) { [weak self] in
            self?.navigate(to: RoutingRequest(path: "/transfer"), animated: true, completion: nil)
        }
    }

    private var help: dydxSimpleUIMarketsHeaderViewModel.MenuItem {
        dydxSimpleUIMarketsHeaderViewModel.MenuItem(
            icon: "icon_help",
            title: DataLocalizer.localize(path: "APP.HEADER.HELP")) { [weak self] in
                self?.navigate(to: RoutingRequest(path: "/help"), animated: true, completion: nil)
            }
    }

    private var switchMode: dydxSimpleUIMarketsHeaderViewModel.MenuItem { dydxSimpleUIMarketsHeaderViewModel.MenuItem(
        icon: "icon_switch",
        title: DataLocalizer.localize(path: "APP.TRADE.MODE.SWITCH_TO_PRO"),
        subtitle: DataLocalizer.localize(path: "APP.TRADE.MODE.FULLY_FEATURED")) { [weak self] in
            self?.navigate(to: RoutingRequest(path: "/action/mode/switch",
                                              params: ["mode": "pro"]),
                           animated: true, completion: nil)
        }
    }
}
