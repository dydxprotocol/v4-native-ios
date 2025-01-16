//
//  dydxSimpleUIMarketDetailsViewPresenter.swift
//  dydxPresenters
//
//  Created by Rui Huang on 15/01/2025.
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

protocol dydxSimpleUIMarketDetailsViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxSimpleUIMarketDetailsViewModel? { get }
}

class dydxSimpleUIMarketDetailsViewPresenter: HostedViewPresenter<dydxSimpleUIMarketDetailsViewModel>, dydxSimpleUIMarketDetailsViewPresenterProtocol {
    @Published var marketId: String?

    var onContentChanged: ((SharedMarketViewModel?) -> Void)?

    private let marketPresenter = SharedMarketPresenter()
    private lazy var childPresenters: [HostedViewPresenterProtocol] = [
        marketPresenter
    ]

    override init() {
        let viewModel = dydxSimpleUIMarketDetailsViewModel()

        super.init()

        self.viewModel = viewModel

        $marketId.assign(to: &marketPresenter.$marketId)

        attachChildren(workers: childPresenters)
    }

    override func start() {
        super.start()

        marketPresenter.$viewModel
            .sink { [weak self] viewModel in
                self?.viewModel?.sharedMarketViewModel = viewModel
                self?.onContentChanged?(viewModel)
            }
            .store(in: &subscriptions)

//        Publishers
//            .CombineLatest3($marketId,
//                            AbacusStateManager.shared.state.marketMap,
//                            AbacusStateManager.shared.state.assetMap)
//            .sink { [weak self] marketId, marketMap, _ in
//                guard let marketId = marketId, let market = marketMap[marketId] else { return }
//                let tickSizeNumDecimals = market.configs?.displayTickSizeDecimals?.intValue ?? 0
//                let stepSizeNumDecimals = market.configs?.displayStepSizeDecimals?.intValue ?? 0
////                self?.updateStats(market: market, asset: assetMap[market.assetId], stepSizeNumDecimals: stepSizeNumDecimals, tickSizeNumDecimals: tickSizeNumDecimals)
//            }
//            .store(in: &subscriptions)
    }
}
