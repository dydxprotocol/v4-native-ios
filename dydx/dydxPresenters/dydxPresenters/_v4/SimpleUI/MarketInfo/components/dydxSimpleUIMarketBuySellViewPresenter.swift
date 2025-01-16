//
//  dydxSimpleUIMarketBuySellViewPresenter.swift
//  dydxPresenters
//
//  Created by Rui Huang on 16/01/2025.
//

import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI

protocol dydxSimpleUIMarketBuySellViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxSimpleUIMarketBuySellViewModel? { get }
}

class dydxSimpleUIMarketBuySellViewPresenter: HostedViewPresenter<dydxSimpleUIMarketBuySellViewModel>, dydxSimpleUIMarketBuySellViewPresenterProtocol {
    override init() {
        super.init()

        viewModel = dydxSimpleUIMarketBuySellViewModel()
    }
}
