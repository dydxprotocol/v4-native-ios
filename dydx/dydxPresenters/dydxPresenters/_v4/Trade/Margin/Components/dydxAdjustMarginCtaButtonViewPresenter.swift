//
//  dydxAdjustMarginCtaButtonViewPresenter.swift
//  dydxPresenters
//
//  Created by Rui Huang on 09/05/2024.
//

import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI

protocol dydxAdjustMarginCtaButtonViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxAdjustMarginCtaButtonViewModel? { get }
}

class dydxAdjustMarginCtaButtonViewPresenter: HostedViewPresenter<dydxAdjustMarginCtaButtonViewModel>, dydxAdjustMarginCtaButtonViewPresenterProtocol {
    override init() {
        super.init()

        viewModel = dydxAdjustMarginCtaButtonViewModel()
    }
}
