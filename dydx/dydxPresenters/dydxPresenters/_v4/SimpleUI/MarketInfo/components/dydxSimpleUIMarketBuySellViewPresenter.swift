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
    @Published var marketId: String?

    override init() {
        super.init()

        viewModel = dydxSimpleUIMarketBuySellViewModel()

        viewModel?.buyAction = { [weak self] in
            guard let marketId = self?.marketId else { return }
            Router.shared?.navigate(to: RoutingRequest(path: "/trade/simple",
                                                       params: ["side": "buy", "market": marketId]), animated: true, completion: nil)
        }

        viewModel?.sellAction = { [weak self] in
            guard let marketId = self?.marketId else { return }
            Router.shared?.navigate(to: RoutingRequest(path: "/trade/simple",
                                                       params: ["side": "sell", "market": marketId]), animated: true, completion: nil)
        }
    }
}
