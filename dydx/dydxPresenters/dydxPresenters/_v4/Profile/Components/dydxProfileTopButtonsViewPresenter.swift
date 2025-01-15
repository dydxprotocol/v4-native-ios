//
//  dydxProfileTopButtonsViewPresenter.swift
//  dydxPresenters
//
//  Created by Rui Huang on 14/01/2025.
//

import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI
import dydxStateManager
import dydxFormatter
import Combine

protocol dydxProfileTopButtonsViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxProfileTopButtonsViewModel? { get }
}

class dydxProfileTopButtonsViewPresenter: HostedViewPresenter<dydxProfileTopButtonsViewModel>, dydxProfileTopButtonsViewPresenterProtocol {
    override init() {
        super.init()

        viewModel = dydxProfileTopButtonsViewModel()

        viewModel?.settingsAction = {
            Router.shared?.navigate(to: RoutingRequest(path: "/settings"), animated: true, completion: nil)
        }

        viewModel?.modeAction = {
            Router.shared?.navigate(to: RoutingRequest(path: "/settings/app_mode"), animated: true, completion: nil)
        }

        viewModel?.alertsAction = {
            Router.shared?.navigate(to: RoutingRequest(path: "/alerts"), animated: true, completion: nil)
        }
    }

    override func start() {
        super.start()

        Publishers
            .CombineLatest(
                AbacusStateManager.shared.state.onboarded,
                AbacusStateManager.shared.state.alerts)
            .sink { [weak self] onboarded, alerts in
                self?.viewModel?.hasNewAlerts = alerts.count > 0 && onboarded
            }
            .store(in: &self.subscriptions)
    }
}
