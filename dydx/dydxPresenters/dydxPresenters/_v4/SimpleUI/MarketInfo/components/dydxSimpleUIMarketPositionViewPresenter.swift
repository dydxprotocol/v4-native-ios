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

    override init() {
        super.init()

        viewModel = dydxSimpleUIMarketPositionViewModel()
    }

    override func start() {
        super.start()

        Publishers
            .CombineLatest4(AbacusStateManager.shared.state.selectedSubaccountPositions,
                           $marketId,
                           AbacusStateManager.shared.state.marketMap,
                           AbacusStateManager.shared.state.assetMap)
            .sink { [weak self] position, marketId, marketMap, assetMap in
                let position = position.first { position in
                    position.id == marketId &&
                    (position.side.current == Abacus.PositionSide.long_ || position.side.current == Abacus.PositionSide.short_)
                }
                self?.updatePositionSection(position: position, marketMap: marketMap, assetMap: assetMap)
            }
            .store(in: &subscriptions)
    }

    private func updatePositionSection(position: SubaccountPosition?, marketMap: [String: PerpetualMarket], assetMap: [String: Asset]) {
        guard let position, let sharedOrderViewModel = dydxPortfolioPositionsViewPresenter.createPositionViewModelItem(position: position,
                                                                                                                       marketMap: marketMap,
                                                                                                                       assetMap: assetMap)
        else {
            viewModel?.side = nil       // hide the view
            return
        }

        viewModel?.symbol = sharedOrderViewModel.token?.symbol
        viewModel?.unrealizedPNLAmount = sharedOrderViewModel.unrealizedPnl
        viewModel?.size = sharedOrderViewModel.size
        viewModel?.side = SideTextViewModel(side: sharedOrderViewModel.sideText.side, coloringOption: .withBackground)
        viewModel?.liquidationPrice = sharedOrderViewModel.liquidationPrice
        viewModel?.entryPrice = sharedOrderViewModel.entryPrice

        viewModel?.logoUrl = sharedOrderViewModel.logoUrl
        viewModel?.amount = dydxFormatter.shared.dollar(number: position.notionalTotal.current?.doubleValue, digits: 2)
        viewModel?.funding = SignedAmountViewModel(amount: position.netFunding?.doubleValue, displayType: .dollar, coloringOption: .allText)
    }
}
