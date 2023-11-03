//
//  dydxOrderbookSideViewPresenter.swift
//  dydxUI
//
//  Created by Michael Maguire on 7/12/23.
//  Copyright © 2023 dYdX Trading Inc. All rights reserved.
//

import Abacus
import dydxStateManager
import dydxViews
import ParticlesKit
import PlatformParticles
import PlatformUI
import RoutingKit
import SwiftUI
import Utilities
import Combine
import dydxFormatter

private protocol dydxTradeInputSideViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxTradeInputSideViewModel? { get }
}

class dydxTradeInputSideViewPresenter: HostedViewPresenter<dydxTradeInputSideViewModel>, dydxTradeInputSideViewPresenterProtocol {
    override init() {
        super.init()

        viewModel = dydxTradeInputSideViewModel(onEdited: { value in
            AbacusStateManager.shared.trade(input: value, type: TradeInputField.side)
        })
    }

    override func start() {
        super.start()

        AbacusStateManager.shared.state.tradeInput.sink { [weak self] tradeInput in
            guard let self = self else { return }
            if let sideOptions = tradeInput?.options?.sideOptions {
                self.viewModel?.options = AbacusUtils.translate(options: sideOptions)
                self.viewModel?.value = tradeInput?.side?.rawValue
            }
        }
        .store(in: &subscriptions)
    }
}
