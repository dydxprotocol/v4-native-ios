//
//  dydxSimpleUIMarketSearchViewPresenter.swift
//  dydxPresenters
//
//  Created by Rui Huang on 19/12/2024.
//

import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI

protocol dydxSimpleUIMarketSearchViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxSimpleUIMarketSearchViewModel? { get }
}

class dydxSimpleUIMarketSearchViewPresenter: HostedViewPresenter<dydxSimpleUIMarketSearchViewModel>, dydxSimpleUIMarketSearchViewPresenterProtocol {
    override init() {
        super.init()

        viewModel = dydxSimpleUIMarketSearchViewModel()
    }
}
