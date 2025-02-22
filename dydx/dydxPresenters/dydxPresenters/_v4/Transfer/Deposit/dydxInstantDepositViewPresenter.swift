//
//  dydxInstantDepositViewPresenter.swift
//  dydxPresenters
//
//  Created by Rui Huang on 21/02/2025.
//

import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI

protocol dydxInstantDepositViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxInstantDepositViewModel? { get }
}

class dydxInstantDepositViewPresenter: HostedViewPresenter<dydxInstantDepositViewModel>, dydxInstantDepositViewPresenterProtocol {
    override init() {
        super.init()

        viewModel = dydxInstantDepositViewModel.previewValue
        viewModel?.input?.assetAction = {
            Router.shared?.navigate(to: RoutingRequest(path: "/transfer/deposit/search", params: nil), animated: true, completion: nil)
         }
    }
}
