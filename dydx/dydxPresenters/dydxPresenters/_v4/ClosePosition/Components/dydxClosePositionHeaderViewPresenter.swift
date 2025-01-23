//
//  dydxClosePositionHeaderViewBuilder.swift
//  dydxPresenters
//
//  Created by Rui Huang on 2/21/23.
//

import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI
import Abacus
import dydxStateManager
import Combine

protocol dydxClosePositionHeaderViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxClosePositionHeaderViewModel? { get }
}

class dydxClosePositionHeaderViewPresenter: HostedViewPresenter<dydxClosePositionHeaderViewModel>, dydxClosePositionHeaderViewPresenterProtocol {
    override init() {
        super.init()

        viewModel = dydxClosePositionHeaderViewModel()
    }

    override func start() {
        super.start()

        let marketPublisher = AbacusStateManager.shared.state.closePositionInput
            .compactMap { $0?.marketId }
            .flatMap { AbacusStateManager.shared.state.market(of: $0) }
            .compactMap { $0 }
            .eraseToAnyPublisher()

        Publishers
            .CombineLatest3(
                marketPublisher,
                AbacusStateManager.shared.state.selectedSubaccountPositions,
                AbacusStateManager.shared.state.assetMap)
            .sink { [weak self] market, subaccountPositions, assetMap in
                let position = subaccountPositions.first { (subaccountPosition: SubaccountPosition) in
                    subaccountPosition.id == market.id
                }
                if let position = position {
                    self?.updateHeader(market: market, position: position, assetMap: assetMap)
                }
            }
            .store(in: &subscriptions)
    }

    private func updateHeader(market: PerpetualMarket, position: SubaccountPosition, assetMap: [String: Asset]) {
        let asset = assetMap[market.assetId]
        viewModel?.sharedMarketViewModel = SharedMarketPresenter.createViewModel(market: market, asset: asset)
        viewModel?.sideViewModel = SideTextViewModel(side: position.side.current == PositionSide.long_ ? .long : .short,
                                                     coloringOption: .colored)
    }
}
