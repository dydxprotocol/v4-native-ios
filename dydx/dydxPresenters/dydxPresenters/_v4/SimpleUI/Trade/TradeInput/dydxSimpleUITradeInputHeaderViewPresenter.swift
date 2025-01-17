//
//  dydxSimpleUITradeInputHeaderViewPresenter.swift
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
import Abacus
import Combine
import dydxStateManager
import dydxFormatter

protocol dydxSimpleUITradeInputHeaderViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxSimpleUITradeInputHeaderViewModel? { get }
}

class dydxSimpleUITradeInputHeaderViewPresenter: HostedViewPresenter<dydxSimpleUITradeInputHeaderViewModel>, dydxSimpleUITradeInputHeaderViewPresenterProtocol {
    @Published var marketId: String?

    private let marketPresenter = SharedMarketPresenter()
    private lazy var childPresenters: [HostedViewPresenterProtocol] = [
        marketPresenter
    ]

    override init() {
        let viewModel = dydxSimpleUITradeInputHeaderViewModel()

        marketPresenter.$viewModel.assign(to: &viewModel.$sharedMarketViewModel)

        super.init()

        self.viewModel = viewModel

        $marketId.assign(to: &marketPresenter.$marketId)

        attachChildren(workers: childPresenters)
    }

    override func start() {
        super.start()

        AbacusStateManager.shared.state.tradeInput
            .compactMap { $0 }
            .removeDuplicates()
            .sink { [weak self] tradeInput in
                self?.marketPresenter.marketId = tradeInput.marketId
                let side: SideTextViewModel.Side?
                switch tradeInput.side {
                case .buy:
                    side = .buy
                case .sell:
                    side = .sell
                default:
                    side = nil
                }
                if let side {
                    self?.viewModel?.side = SideTextViewModel(side: side)
                }
            }
            .store(in: &subscriptions)
    }
}
