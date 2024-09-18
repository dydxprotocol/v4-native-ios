//
//  dydxSettingsHelpRowViewPresenter.swift
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

protocol dydxSettingsHelpRowViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxSettingsSecondaryActionsViewModel? { get }
}

class dydxSettingsHelpRowViewPresenter: HostedViewPresenter<dydxSettingsSecondaryActionsViewModel>, dydxSettingsHelpRowViewPresenterProtocol {
    init(viewModel: dydxSettingsSecondaryActionsViewModel) {
        super.init()

        self.viewModel = viewModel

        viewModel.settingsAction = {
            Router.shared?.navigate(to: RoutingRequest(path: "/settings"), animated: true, completion: nil)
        }

        viewModel.helpAction = {
            Router.shared?.navigate(to: RoutingRequest(path: "/help"), animated: true, completion: nil)
        }
        
        AbacusStateManager.shared.state.onboarded
            .sink { [weak self] onboarded in
                // do not show alerts if wallet not connected
                if onboarded && dydxBoolFeatureFlag.isVaultEnabled.isEnabled {
                    self?.viewModel?.alertsAction = {
                        Router.shared?.navigate(to: RoutingRequest(path: "/alerts"), animated: true, completion: nil)
                    }
                }
                
            }
            .store(in: &self.subscriptions)
    }
}
