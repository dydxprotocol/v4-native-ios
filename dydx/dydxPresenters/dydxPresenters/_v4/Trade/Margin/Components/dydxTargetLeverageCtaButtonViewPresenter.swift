//
//  dydxTargetLeverageCtaButtonViewPresenter.swift
//  dydxPresenters
//
//  Created by Rui Huang on 08/05/2024.
//

import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI

protocol dydxTargetLeverageCtaButtonViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxTargetLeverageCtaButtonViewModel? { get }
}

class dydxTargetLeverageCtaButtonViewPresenter: HostedViewPresenter<dydxTargetLeverageCtaButtonViewModel>, dydxTargetLeverageCtaButtonViewPresenterProtocol {
    override init() {
        super.init()

        viewModel = dydxTargetLeverageCtaButtonViewModel()
    }
}
