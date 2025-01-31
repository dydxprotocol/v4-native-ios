//
//  dydxSimpleUiMarketLaunchableViewPresenter.swift
//  dydxPresenters
//
//  Created by Rui Huang on 01/02/2025.
//

import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI
import Combine
import dydxStateManager
import Abacus
import dydxFormatter
import SwiftUI

protocol dydxSimpleUiMarketLaunchableViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxSimpleUiMarketLaunchableViewModel? { get }
}

class dydxSimpleUiMarketLaunchableViewPresenter: HostedViewPresenter<dydxSimpleUiMarketLaunchableViewModel>, dydxSimpleUiMarketLaunchableViewPresenterProtocol {
    @Published var marketId: String?

    private let marketPresenter = SharedMarketPresenter()
    private lazy var childPresenters: [HostedViewPresenterProtocol] = [
        marketPresenter
    ]

    override init() {
        super.init()

        $marketId.assign(to: &marketPresenter.$marketId)

        attachChildren(workers: childPresenters)
    }

    override func start() {
        super.start()

        Publishers
            .CombineLatest4($marketId,
                            AbacusStateManager.shared.state.marketMap,
                            AbacusStateManager.shared.state.assetMap,
                            marketPresenter.$viewModel)
            .sink { [weak self] marketId, marketMap, assetMap, marketViewModel in
                guard let marketId, let market = marketMap[marketId], let asset = assetMap[market.assetId] else {
                    return
                }
                if market.isLaunched {
                    self?.viewModel = nil
                } else {
                    self?.viewModel = self?.createViewModel(market: market, asset: asset, marketViewModel: marketViewModel)
                }
            }
            .store(in: &subscriptions)
    }

    private func createViewModel(market: PerpetualMarket, asset: Asset, marketViewModel: SharedMarketViewModel?) -> dydxSimpleUiMarketLaunchableViewModel {
        let viewModel = dydxSimpleUiMarketLaunchableViewModel()
        viewModel.sharedMarketViewModel = marketViewModel
        return viewModel
    }
}
