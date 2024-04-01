//
//  dydxMarketPositionViewPresenter.swift
//  dydxPresenters
//
//  Created by Rui Huang on 1/11/23.
//

import Abacus
import Combine
import dydxStateManager
import dydxViews
import ParticlesKit
import PlatformParticles
import PlatformUI
import RoutingKit
import Utilities
import dydxFormatter

protocol dydxMarketPositionViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxMarketPositionViewModel? { get }
}

class dydxMarketPositionViewPresenter: HostedViewPresenter<dydxMarketPositionViewModel>, dydxMarketPositionViewPresenterProtocol {
    @Published var position: SubaccountPosition?

    init(viewModel: dydxMarketPositionViewModel?) {
        super.init()

        self.viewModel = viewModel

        // hide for now until feature work complete
        #if DEBUG
        viewModel?.takeProfitStopLossAction = {[weak self] in
            if let assetId = self?.position?.assetId {
                Router.shared?.navigate(to: RoutingRequest(path: "/trade/take_proft_stop_loss", params: ["marketId": "\(assetId)-USD"]), animated: true, completion: nil)
            }
        }
        #endif
        viewModel?.closeAction = {[weak self] in
            if let assetId = self?.position?.assetId {
                Router.shared?.navigate(to: RoutingRequest(path: "/trade/close", params: ["marketId": "\(assetId)-USD"]), animated: true, completion: nil)
            }
        }
    }

    override func start() {
        super.start()

        Publishers
            .CombineLatest3($position.compactMap { $0 }.removeDuplicates(),
                            AbacusStateManager.shared.state.marketMap,
                            AbacusStateManager.shared.state.assetMap)
            .sink { [weak self] position, marketMap, assetMap in
                self?.updatePosition(position: position, marketMap: marketMap, assetMap: assetMap)
            }
            .store(in: &subscriptions)
    }

    private func updatePosition(position: SubaccountPosition, marketMap: [String: PerpetualMarket], assetMap: [String: Asset]) {
        guard let sharedOrderViewModel = dydxPortfolioPositionsViewPresenter.createViewModelItem(position: position, marketMap: marketMap, assetMap: assetMap) else {
            return
        }

        guard let market = marketMap[position.id], let configs = market.configs else {
            return
        }

        viewModel?.unrealizedPNLAmount = sharedOrderViewModel.unrealizedPnl
        viewModel?.unrealizedPNLPercent = sharedOrderViewModel.unrealizedPnlPercent
        viewModel?.realizedPNLAmount = SignedAmountViewModel(amount: position.realizedPnl?.current?.doubleValue, displayType: .dollar, coloringOption: .allText)
        viewModel?.liquidationPrice = dydxFormatter.shared.dollar(number: position.liquidationPrice?.current?.doubleValue, digits: configs.displayTickSizeDecimals?.intValue ?? 0)

        viewModel?.leverage = sharedOrderViewModel.leverage
        viewModel?.leverageIcon = sharedOrderViewModel.leverageIcon
        viewModel?.size = sharedOrderViewModel.size
        viewModel?.side = sharedOrderViewModel.sideText
        viewModel?.token = sharedOrderViewModel.token
        viewModel?.logoUrl = sharedOrderViewModel.logoUrl
        viewModel?.gradientType = sharedOrderViewModel.gradientType

        viewModel?.amount = dydxFormatter.shared.dollar(number: position.valueTotal?.current?.doubleValue, digits: configs.displayTickSizeDecimals?.intValue ?? 0)

        viewModel?.openPrice = dydxFormatter.shared.dollar(number: position.entryPrice?.current?.doubleValue, digits: configs.displayTickSizeDecimals?.intValue ?? 0)
        viewModel?.closePrice = dydxFormatter.shared.dollar(number: position.exitPrice?.doubleValue, digits: configs.displayTickSizeDecimals?.intValue ?? 0)

        viewModel?.funding = SignedAmountViewModel(amount: position.netFunding?.doubleValue, displayType: .dollar, coloringOption: .allText)
    }
}
