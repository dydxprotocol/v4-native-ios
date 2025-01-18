//
//  dydxSimpleUIBuyingPowerViewPresenter.swift
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
import SwiftUI
import Combine
import dydxFormatter
import Abacus
import dydxStateManager

protocol dydxSimpleUIBuyingPowerView1PresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxSimpleUIBuyingPowerViewModel? { get }
}

class dydxSimpleUIBuyingPowerViewPresenter: HostedViewPresenter<dydxSimpleUIBuyingPowerViewModel>, dydxSimpleUIBuyingPowerView1PresenterProtocol {
    override init() {
        super.init()

        viewModel = dydxSimpleUIBuyingPowerViewModel()
    }

    override func start() {
        super.start()

        AbacusStateManager.shared.state.selectedSubaccount
            .sink { [weak self] selectedSubaccount in
                self?.viewModel?.buyingPower = dydxFormatter.shared.dollar(number: selectedSubaccount?.buyingPower?.current?.doubleValue.filter(filter: .notNegative), digits: 2)
            }
            .store(in: &subscriptions)
    }
}
