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
    @Published var side: OrderSide?

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

        let sidePublisher: AnyPublisher<(OrderSide?, Subaccount?), Never> =
        Publishers.CombineLatest(
            $side,
            AbacusStateManager.shared.state.selectedSubaccount
            )
        .compactMap { ($0, $1) }
        .eraseToAnyPublisher()

        Publishers
            .CombineLatest4(
                $tradeType,
                sidePublisher,
                AbacusStateManager.shared.state.tradeInput,
                AbacusStateManager.shared.state.closePositionInput
            )
            .sink { [weak self] tradeType, sideVal, tradeInput, closePositionInput in
                let (side, subaccount) = sideVal
                switch tradeType {
                case .trade:
                    self?.update(tradeInput: tradeInput, requestedSide: side, subaccount: subaccount)
                case .closePosition:
                    self?.update(closePositionInput: closePositionInput)
                }
            }
            .store(in: &subscriptions)
    }

    private func update(tradeInput: TradeInput?, requestedSide: OrderSide?, subaccount: Subaccount?) {
        guard let tradeInput else {
            viewModel?.side = nil
            return
        }
        marketPresenter.marketId = tradeInput.marketId
        let side: SideTextViewModel.Side?
        if subaccount?.equity?.current != nil {
            switch tradeInput.side {
            case .buy:
                side = .long
            case .sell:
                side = .short
            default:
                side = nil
            }
        } else {
            switch requestedSide {
            case .buy:
                side = .long
            case .sell:
                side = .short
            default:
                side = nil
            }
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
