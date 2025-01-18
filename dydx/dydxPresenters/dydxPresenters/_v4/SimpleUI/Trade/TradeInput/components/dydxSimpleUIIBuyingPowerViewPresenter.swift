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

        Publishers
            .CombineLatest3(
                AbacusStateManager.shared.state.selectedSubaccount,
                AbacusStateManager.shared.state.tradeInput
                    .compactMap { $0 }
                    .removeDuplicates(),
                AbacusStateManager.shared.state.configsAndAssetMap)
            .sink { [weak self] selectedSubaccount, tradeInput, configsAndAssetMap in
                if let marketId = tradeInput.marketId,
                   let imf = configsAndAssetMap[marketId]?.configs?.initialMarginFraction?.doubleValue, imf > 0,
                   let freeCollateral = selectedSubaccount?.freeCollateral?.current?.doubleValue {
                    let buyingPower = freeCollateral * (1.0 / imf)
                    self?.viewModel?.buyingPower = dydxFormatter.shared.dollar(number: buyingPower.filter(filter: .notNegative), digits: 2)
                }
            }
            .store(in: &subscriptions)
    }
}
