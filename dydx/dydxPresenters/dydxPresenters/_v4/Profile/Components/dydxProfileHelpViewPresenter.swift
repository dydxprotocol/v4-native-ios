//
//  dydxProfileHelpViewPresenter.swift
//  dydxPresenters
//
//  Created by Rui Huang on 24/01/2025.
//

import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI

protocol dydxProfileHelpViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxProfileHelpViewModel? { get }
}

class dydxProfileHelpViewPresenter: HostedViewPresenter<dydxProfileHelpViewModel>, dydxProfileHelpViewPresenterProtocol {
    override init() {
        super.init()

        viewModel = dydxProfileHelpViewModel()

        viewModel?.helpAction = {
            Router.shared?.navigate(to: RoutingRequest(path: "/help"), animated: true, completion: nil)
        }
    }
}
