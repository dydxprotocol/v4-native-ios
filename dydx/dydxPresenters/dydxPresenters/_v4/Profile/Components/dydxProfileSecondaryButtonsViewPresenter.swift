//
//  dydxProfileSecondaryButtonsViewPresenter.swift
//  dydxPresenters
//
//  Created by Michael Maguire on 11/9/23.
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

protocol dydxProfileSecondaryButtonsViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxProfileSecondaryButtonsViewModel? { get }
}

class dydxProfileSecondaryButtonsViewPresenter: HostedViewPresenter<dydxProfileSecondaryButtonsViewModel>, dydxProfileSecondaryButtonsViewPresenterProtocol {

    init(viewModel: dydxProfileSecondaryButtonsViewModel) {
        super.init()

        self.viewModel = viewModel

        viewModel.settingsAction = {
            Router.shared?.navigate(to: RoutingRequest(path: "/settings"), animated: true, completion: nil)
        }

        viewModel.helpAction = {
            Router.shared?.navigate(to: RoutingRequest(path: "/help"), animated: true, completion: nil)
        }
    }

    override func start() {
        super.start()

        Publishers
            .CombineLatest(
                AbacusStateManager.shared.state.onboarded,
                AbacusStateManager.shared.state.alerts)
            .sink { [weak self] onboarded, alerts in
                // do not show alerts if wallet not connected
                if onboarded && dydxBoolFeatureFlag.isVaultEnabled.isEnabled {
                    self?.viewModel?.alertsAction = {
                        Router.shared?.navigate(to: RoutingRequest(path: "/alerts"), animated: true, completion: nil)
                    }
                    self?.viewModel?.hasNewAlerts = alerts.count > 0
                }
            }
            .store(in: &self.subscriptions)
    }
}
