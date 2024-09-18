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
        
        viewModel.alertsAction = {
            Router.shared?.navigate(to: RoutingRequest(path: "/alerts"), animated: true, completion: nil)
        }
    }
}
