//
//  dydxMarketOrderbookPresenter.swift
//  dydxPresenters
//
//  Created by Rui Huang on 10/2/23.
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

protocol dydxMarketOrderbookPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxMarketOrderbookViewModel? { get }
}

class dydxMarketOrderbookPresenter: HostedViewPresenter<dydxMarketOrderbookViewModel>, dydxMarketOrderbookPresenterProtocol {
    @Published var marketId: String?

    private let orderbookPresenter = dydxOrderbookPresenter()
    private let orderbookGroupPresenter = dydxOrderbookGroupViewPresenter()

    private lazy var childPresenters: [HostedViewPresenterProtocol] = [
        orderbookPresenter,
        orderbookGroupPresenter
   ]

    override init() {
        let viewModel = dydxMarketOrderbookViewModel()

        orderbookGroupPresenter.$viewModel.assign(to: &viewModel.$group)

        super.init()

        self.viewModel = viewModel
    }

    override func start() {
        super.start()

        $marketId
            .sink { [weak self] marketId in
                self?.orderbookPresenter.marketId = marketId
                self?.orderbookGroupPresenter.marketId = marketId
            }
            .store(in: &subscriptions)

        orderbookPresenter.$viewModel
            .sink { [weak self] orderbook in
                self?.viewModel?.asks = orderbook?.asks
                self?.viewModel?.asks?.displayStyle = .sideBySide
                self?.viewModel?.bids = orderbook?.bids
                self?.viewModel?.bids?.displayStyle = .sideBySide
                self?.viewModel?.spread = orderbook?.spread
            }
            .store(in: &subscriptions)

        attachChildren(workers: childPresenters)
    }
}
