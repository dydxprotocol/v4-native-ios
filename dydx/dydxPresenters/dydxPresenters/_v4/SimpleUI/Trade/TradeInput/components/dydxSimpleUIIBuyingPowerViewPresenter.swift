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
                guard let marketId = tradeInput.marketId, let freeCollateral = selectedSubaccount?.freeCollateral?.current?.doubleValue  else {
                    return
                }

                let existingPosition = selectedSubaccount?.openPositions?.first { $0.id == marketId
                }

                let positionSide = existingPosition?.side.current ?? .none
                let isOpposite = tradeInput.side?.isOppositeOf(that: positionSide) ?? false

                let offsettingValue: Double
                if isOpposite {
                    offsettingValue = 2 * ( existingPosition?.notionalTotal.current?.doubleValue ?? 0.0)
                } else {
                    offsettingValue = 0.0
                }

                if tradeInput.marginMode == .isolated {
                    if tradeInput.targetLeverage > 0 {
                        let buyingPower = freeCollateral * tradeInput.targetLeverage + offsettingValue
                        self?.viewModel?.buyingPower = dydxFormatter.shared.dollar(number: buyingPower.filter(filter: .notNegative), digits: 2)
                    } else {
                        self?.viewModel?.buyingPower = nil
                    }
                } else {
                    if let imf = configsAndAssetMap[marketId]?.configs?.initialMarginFraction?.doubleValue, imf > 0 {
                        let buyingPower = freeCollateral * (1.0 / imf) + offsettingValue
                        self?.viewModel?.buyingPower = dydxFormatter.shared.dollar(number: buyingPower.filter(filter: .notNegative), digits: 2)
                    } else {
                        self?.viewModel?.buyingPower = nil
                    }
                }
            }
            .store(in: &subscriptions)
    }
}
