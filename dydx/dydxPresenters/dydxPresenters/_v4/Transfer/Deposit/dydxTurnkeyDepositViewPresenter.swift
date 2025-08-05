//
//  dydxTurnkeyDepositViewPresenter.swift
//  dydxPresenters
//
//  Created by Rui Huang on 04/08/2025.
//

import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI
import dydxStateManager

protocol dydxTurnkeyDepositViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxTurnkeyDepositViewModel? { get }
}

class dydxTurnkeyDepositViewPresenter: HostedViewPresenter<dydxTurnkeyDepositViewModel>, dydxTurnkeyDepositViewPresenterProtocol {
    override init() {
        super.init()

        viewModel = dydxTurnkeyDepositViewModel()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            AbacusStateManager.shared.startTrade()
            AbacusStateManager.shared.startTransfer()
        }
    }
}
