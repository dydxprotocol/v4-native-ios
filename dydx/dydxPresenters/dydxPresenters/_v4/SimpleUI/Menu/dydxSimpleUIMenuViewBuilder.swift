//
//  dydxSimpleUIMenuViewBuilder.swift
//  dydxPresenters
//
//  Created by Rui Huang on 18/04/2025.
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

public class dydxSimpleUIMenuViewBuilder: NSObject, ObjectBuilderProtocol {
    public func build<T>() -> T? {
        let presenter = dydxSimpleUIMenuViewPresenter()
        let view = presenter.viewModel?.createView() ?? PlatformViewModel().createView()
        return dydxSimpleUIMenuViewController(presenter: presenter, view: view, configuration: .fullScreenSheet) as? T
    }
}

private class dydxSimpleUIMenuViewController: HostingViewController<PlatformView, dydxSimpleUIMenuViewModel> {
    override public func arrive(to request: RoutingRequest?, animated: Bool) -> Bool {
        if request?.path == "/simple_ui/menu" {
            return true
        }
        return false
    }
}

private protocol dydxSimpleUIMenuViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxSimpleUIMenuViewModel? { get }
}

private class dydxSimpleUIMenuViewPresenter: HostedViewPresenter<dydxSimpleUIMenuViewModel>, dydxSimpleUIMenuViewPresenterProtocol {
    private let accountPresenter = dydxSimpleUIMenuAccountViewPresenter()
    private let buttonsPresenter = dydxSimpleUIMenuButtonsViewPresenter()

    private lazy var childPresenters: [HostedViewPresenterProtocol] = [
        accountPresenter,
        buttonsPresenter
    ]

    override init() {
        let viewModel = dydxSimpleUIMenuViewModel()

        accountPresenter.$viewModel.assign(to: &viewModel.$account)
        buttonsPresenter.$viewModel.assign(to: &viewModel.$buttons)

        super.init()

        viewModel.switchModeAction = { [weak self] in
            let showAppModeSurvey = SettingsStore.shared?.value(forDydxKey: .showAppModeSurvey) as? Bool ?? false
            if showAppModeSurvey {
                self?.navigate(to: RoutingRequest(path: "/settings/app_mode_survey"), animated: true, completion: nil)
            } else {
                self?.navigate(to: RoutingRequest(path: "/action/mode/switch",
                                                  params: ["mode": "pro"]),
                               animated: true, completion: nil)
            }
        }

        self.viewModel = viewModel

        attachChildren(workers: childPresenters)
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
            viewModel?.items = [accountItem(wallet: currentWallet), alerts, history, settings, help, signOut(ethereumAddress: ethereumAddress)]
        } else {
            viewModel?.items = [settings, help]
            viewModel?.depositAction = nil
            viewModel?.withdrawAction = nil
        }
    }

    private var signIn: dydxSimpleUIMenuViewModel.MenuItem {
        dydxSimpleUIMenuViewModel.MenuItem(
        icon: "icon_wallet_connect",
        title: DataLocalizer.localize(path: "APP.TURNKEY_ONBOARD.SIGN_IN_TITLE")) { [weak self] in
            self?.navigate(to: RoutingRequest(path: "/action/dismiss"), animated: true) {_, _ in
                self?.navigate(to: RoutingRequest(path: OnboardingLandingRoute.value), animated: true, completion: nil)
            }
        }
    }

    private func signOut(ethereumAddress: String) -> dydxSimpleUIMenuViewModel.MenuItem {
        dydxSimpleUIMenuViewModel.MenuItem(
            icon: "icon_close",
            title: DataLocalizer.localize(path: "APP.GENERAL.SIGN_OUT"),
            destructive: true) { [weak self] in
                self?.navigate(to: RoutingRequest(path: "/action/dismiss"), animated: true) {_, _ in
                    self?.navigate(to: RoutingRequest(path: "/action/wallet/disconnect", params: ["ethereumAddress": ethereumAddress]), animated: true, completion: nil)
                }
            }
    }

    private var settings: dydxSimpleUIMenuViewModel.MenuItem {
        dydxSimpleUIMenuViewModel.MenuItem(
            icon: "icon_settings_1",
            title: DataLocalizer.localize(path: "APP.EMAIL_NOTIFICATIONS.SETTINGS")) { [weak self] in
                self?.navigate(to: RoutingRequest(url: "/settings"), animated: true, completion: nil)
        }
    }

    private func accountItem(wallet: dydxWalletInstance?) -> dydxSimpleUIMenuViewModel.MenuItem {
        dydxSimpleUIMenuViewModel.MenuItem(
            icon: "icon_account",
            title: DataLocalizer.localize(path: "APP.GENERAL.ACCOUNT")) { [weak self] in
                if wallet?.walletId == "turnkey" {
                    self?.navigate(to: RoutingRequest(path: "/profile/security"), animated: true, completion: nil)
                } else {
                    self?.navigate(to: RoutingRequest(path: "/wallets"), animated: true, completion: nil)
                }
            }
    }

    private var alerts: dydxSimpleUIMenuViewModel.MenuItem {
        dydxSimpleUIMenuViewModel.MenuItem(
            icon: "icon_alerts_circle",
            title: DataLocalizer.localize(path: "APP.GENERAL.ALERTS")) { [weak self] in
                self?.navigate(to: RoutingRequest(url: "/alerts"), animated: true, completion: nil)
        }
    }

    private var history: dydxSimpleUIMenuViewModel.MenuItem {
        dydxSimpleUIMenuViewModel.MenuItem(
            icon: "icon_history",
            title: DataLocalizer.localize(path: "APP.GENERAL.HISTORY")) { [weak self] in
                self?.navigate(to: RoutingRequest(path: "/portfolio/history",
                                                  params: ["inTabBar": "false"]),
                               animated: true, completion: nil)
            }
    }

    private var help: dydxSimpleUIMenuViewModel.MenuItem {
        dydxSimpleUIMenuViewModel.MenuItem(
            icon: "icon_help",
            title: DataLocalizer.localize(path: "APP.HEADER.HELP")) { [weak self] in
                self?.navigate(to: RoutingRequest(path: "/help"), animated: true, completion: nil)
            }
    }
}
