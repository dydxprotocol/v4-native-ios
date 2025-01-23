//
//  dydxSimpleUITradeInputPositionViewPresenter.swift
//  dydxPresenters
//
//  Created by Rui Huang on 23/01/2025.
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

protocol dydxSimpleUITradeInputPositionViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxSimpleUITradeInputPositionViewModel? { get }
}

class dydxSimpleUITradeInputPositionViewPresenter: HostedViewPresenter<dydxSimpleUITradeInputPositionViewModel>, dydxSimpleUITradeInputPositionViewPresenterProtocol {
    override init() {
        super.init()

        viewModel = dydxSimpleUITradeInputPositionViewModel()
    }

    override func start() {
        super.start()

        Publishers
            .CombineLatest3(
                AbacusStateManager.shared.state.selectedSubaccountPositions,
                AbacusStateManager.shared.state.closePositionInput,
                AbacusStateManager.shared.state.configsAndAssetMap
            )
            .sink { [weak self] positions, closePositionInput, configsAndAssetMap in
                guard let self, let marketId = closePositionInput?.marketId,
                    let configsAndAsset = configsAndAssetMap[marketId]  else {
                    return
                }

                let position = positions.first { position in
                    position.id == marketId
                }

                let side: AppPositionSide?
                switch position?.side.current {
                case .long_:
                    side = .LONG
                case .short_:
                    side = .SHORT
                default:
                    side = nil
                }
                if let side {
                    self.viewModel?.side = SideTextViewModel(side: .init(positionSide: side), coloringOption: .colored)
                }
                let stepSize = configsAndAsset.configs?.displayStepSizeDecimals?.intValue ?? 1
                self.viewModel?.size = dydxFormatter.shared.localFormatted(number: position?.size.current?.doubleValue, digits: stepSize)
                self.viewModel?.token = configsAndAsset.asset?.displayableAssetId
            }
            .store(in: &subscriptions)

    }
}
