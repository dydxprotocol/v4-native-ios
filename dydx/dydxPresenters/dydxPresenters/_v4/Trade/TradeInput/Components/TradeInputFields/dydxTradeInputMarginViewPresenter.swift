//
//  dydxTradeInputMarginViewPresenter.swift
//  dydxPresenters
//
//  Created by Rui Huang on 07/05/2024.
//

import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI

protocol dydxTradeInputMarginViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxTradeInputMarginViewModel? { get }
}

class dydxTradeInputMarginViewPresenter: HostedViewPresenter<dydxTradeInputMarginViewModel>, dydxTradeInputMarginViewPresenterProtocol {
    override init() {
        super.init()

        viewModel = dydxTradeInputMarginViewModel()
    }

    override func start() {
        super.start()

        // TODO: Fetch from Abacus
        viewModel?.marginMode = DataLocalizer.localize(path: "APP.GENERAL.ISOLATED")
        viewModel?.marginLeverage = "2x"
        
        viewModel?.marginModeAction = {
            Router.shared?.navigate(to: RoutingRequest(path: "/trade/margin_type"), animated: true, completion: nil)
        }
        viewModel?.marginLeverageAction = {
            Router.shared?.navigate(to: RoutingRequest(path: "/trade/target_leverage"), animated: true, completion: nil)
        }
    }
}
