//
//  dydxSearchViewBuilder.swift
//  dydxPresenters
//
//  Created by Rui Huang on 4/10/23.
//

import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI
import Combine

protocol dydxSearchViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxSearchViewModel? { get }
}

class dydxSearchViewPresenter: HostedViewPresenter<dydxSearchViewModel>, dydxSearchViewPresenterProtocol {
    override init() {
        super.init()

        viewModel = dydxSearchViewModel()
        viewModel?.cancelAction = {
            Router.shared?.navigate(to: RoutingRequest(path: "/action/dismiss"), animated: true, completion: nil)
        }
    }
}
