//
//  dydxSimpleUIMarketPositionViewPresenter.swift
//  dydxPresenters
//
//  Created by Rui Huang on 26/12/2024.
//

import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI
import dydxStateManager
import Abacus
import Combine
import dydxFormatter

protocol dydxSimpleUIMarketPositionViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxSimpleUIMarketPositionViewModel? { get }
}

class dydxSimpleUIMarketPositionViewPresenter: HostedViewPresenter<dydxSimpleUIMarketPositionViewModel>, dydxSimpleUIMarketPositionViewPresenterProtocol {
    @Published var marketId: String?

    private let tpSlPresenter = dydxMarketTpSlGroupViewPresenter()

    private lazy var childPresenters: [HostedViewPresenterProtocol] = [
        tpSlPresenter
    ]

    override init() {
        super.init()

        viewModel = dydxSimpleUIMarketPositionViewModel()

        attachChildren(workers: childPresenters)
    }

    override func start() {
        super.start()

        tpSlPresenter.$viewModel
            .sink { [weak self] tpSlGroupViewModel in
                self?.viewModel?.tpSlGroupViewModel = tpSlGroupViewModel
            }
            .store(in: &subscriptions)

        Publishers
            .CombineLatest4(AbacusStateManager.shared.state.selectedSubaccountPositions,
                            $marketId,
                            AbacusStateManager.shared.state.marketMap,
                            AbacusStateManager.shared.state.assetMap)
            .sink { [weak self] positions, marketId, marketMap, assetMap in
                let position = positions.first { position in
                    position.id == marketId &&
                    (position.side.current == Abacus.PositionSide.long_ || position.side.current == Abacus.PositionSide.short_)
                }
                self?.tpSlPresenter.position = position
                self?.updatePositionSection(position: position, marketId: marketId, marketMap: marketMap, assetMap: assetMap)
            }
            .store(in: &subscriptions)
    }

    private func updatePositionSection(position: SubaccountPosition?, marketId: String?, marketMap: [String: PerpetualMarket], assetMap: [String: Asset]) {
        let newViewModel = dydxSimpleUIMarketPositionViewModel()
        newViewModel.tpSlGroupViewModel = viewModel?.tpSlGroupViewModel
        viewModel = newViewModel
        guard let position, let sharedPositionViewModel = dydxPortfolioPositionsViewPresenter.createPositionViewModelItem(position: position,
                                                                                                                       marketMap: marketMap,
                                                                                                                       assetMap: assetMap)
        else {
            viewModel?.hasPosition = false
            viewModel?.side = SideTextViewModel(side: .none, coloringOption: .none)
            if let marketId, let market = marketMap[marketId] {
                viewModel?.symbol = assetMap[market.assetId]?.displayableAssetId
            }
            return
        }

        viewModel?.hasPosition = true
        viewModel?.symbol = sharedPositionViewModel.token?.symbol
        viewModel?.unrealizedPNLAmount = sharedPositionViewModel.unrealizedPnl
        viewModel?.size = sharedPositionViewModel.size
        viewModel?.side = SideTextViewModel(side: sharedPositionViewModel.sideText.side, coloringOption: .colored)
        viewModel?.liquidationPrice = sharedPositionViewModel.liquidationPrice
        viewModel?.entryPrice = sharedPositionViewModel.entryPrice

        viewModel?.logoUrl = sharedPositionViewModel.logoUrl
        viewModel?.amount = dydxFormatter.shared.dollar(number: position.notionalTotal.current?.doubleValue, digits: 2)
        viewModel?.funding = SignedAmountViewModel(amount: position.netFunding?.doubleValue,
                                                   displayType: .dollar,
                                                   coloringOption: .allText,
                                                   noneColor: .textPrimary)

        viewModel?.closeAction = { [weak self] in
            self?.navigate(to: RoutingRequest(path: "/trade/simple/close",
                                              params: ["marketId": position.id]),
                           animated: true, completion: nil)
        }
    }
}
