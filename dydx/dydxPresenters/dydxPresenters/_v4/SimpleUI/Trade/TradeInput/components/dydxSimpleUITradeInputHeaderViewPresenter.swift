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
    @Published var tradeType: TradeSubmission.TradeType = .trade

    private let marketPresenter = SharedMarketPresenter()
    private lazy var childPresenters: [HostedViewPresenterProtocol] = [
        marketPresenter
    ]

    override init() {
        let viewModel = dydxSimpleUITradeInputHeaderViewModel()

        marketPresenter.$viewModel.assign(to: &viewModel.$sharedMarketViewModel)

        super.init()

        self.viewModel = viewModel

        attachChildren(workers: childPresenters)
    }

    override func start() {
        super.start()

        Publishers
            .CombineLatest3(
                $tradeType,
                AbacusStateManager.shared.state.tradeInput,
                AbacusStateManager.shared.state.closePositionInput
            )
            .sink { [weak self] tradeType, tradeInput, closePositionINput in
                switch tradeType {
                case .trade:
                    self?.update(tradeInput: tradeInput)
                case .closePosition:
                    self?.update(closePositionInput: closePositionINput)
                }
            }
            .store(in: &subscriptions)
    }

    private func update(tradeInput: TradeInput?) {
        guard let tradeInput else {
            viewModel?.side = nil
            return
        }
        marketPresenter.marketId = tradeInput.marketId
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
            viewModel?.side = SideTextViewModel(side: side)
        }
    }

    private func update(closePositionInput: ClosePositionInput?) {
        guard let closePositionInput else {
            viewModel?.side = nil
            return
        }
        marketPresenter.marketId = closePositionInput.marketId
        viewModel?.side = SideTextViewModel(side: .custom(DataLocalizer.localize(path: "APP.TRADE.CLOSE_POSITION")), coloringOption: .customColored(ThemeColor.SemanticColor.colorRed))
    }
}
