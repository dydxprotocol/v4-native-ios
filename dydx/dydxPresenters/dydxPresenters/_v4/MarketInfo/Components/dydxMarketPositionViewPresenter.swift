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

        viewModel?.closeAction = {[weak self] in
            if let assetId = self?.position?.assetId {
                Router.shared?.navigate(to: RoutingRequest(path: "/trade/close", params: ["marketId": "\(assetId)-USD"]), animated: true, completion: nil)
            }
        }
    }

    override func start() {
        super.start()

        Publishers
            .CombineLatest4($position.compactMap { $0 }.removeDuplicates(),
                            AbacusStateManager.shared.state.selectedSubaccountOrders,
                            AbacusStateManager.shared.state.marketMap,
                            AbacusStateManager.shared.state.assetMap)
            .sink { [weak self] position, subaccountOrders, marketMap, assetMap in
                self?.updatePosition(position: position, subaccountOrders: subaccountOrders, marketMap: marketMap, assetMap: assetMap)
            }
            .store(in: &subscriptions)
    }

    private func updatePosition(position: SubaccountPosition, subaccountOrders: [SubaccountOrder], marketMap: [String: PerpetualMarket], assetMap: [String: Asset]) {
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

        // hide for now until feature work complete
        #if DEBUG
        let takeProfitOrders = subaccountOrders.filter { (order: SubaccountOrder) in
            order.marketId == position.id && (order.type == .takeprofitmarket || order.type == .takeprofitlimit) && order.side.opposite == position.side.current && order.status == Abacus.OrderStatus.untriggered
        }
        let stopLossOrders = subaccountOrders.filter { (order: SubaccountOrder) in
            order.marketId == position.id && (order.type == .stopmarket || order.type == .stoplimit) && order.side.opposite == position.side.current && order.status == Abacus.OrderStatus.untriggered
        }
        if takeProfitOrders.isEmpty && stopLossOrders.isEmpty {
            viewModel?.takeProfitStatusViewModel = nil
            viewModel?.stopLossStatusViewModel = nil
        } else {
            if takeProfitOrders.count > 1 {
                viewModel?.takeProfitStatusViewModel = .init(triggerSide: .takeProfit, triggerPrice: takeProfitOrders.first?.triggerPrice?.stringValue)
            } else {
                viewModel?.takeProfitStatusViewModel = .init(triggerSide: .takeProfit, triggerPrice: takeProfitOrders.first?.triggerPrice?.stringValue)
            }
            if stopLossOrders.count > 1 {
                viewModel?.stopLossStatusViewModel = .init(triggerSide: .stopLoss, triggerPrice: stopLossOrders.first?.triggerPrice?.stringValue)
            } else {
                viewModel?.stopLossStatusViewModel = .init(triggerSide: .stopLoss, triggerPrice: stopLossOrders.first?.triggerPrice?.stringValue)
            }
        }

        let routeToTakeProfitStopLossAction = {[weak self] in
            if let assetId = self?.position?.assetId {
                Router.shared?.navigate(to: RoutingRequest(path: "/trade/take_profit_stop_loss", params: ["marketId": "\(assetId)-USD"]), animated: true, completion: nil)
            }
        }
        viewModel?.takeProfitStopLossAction = routeToTakeProfitStopLossAction
        viewModel?.takeProfitStatusViewModel?.action = routeToTakeProfitStopLossAction
        viewModel?.stopLossStatusViewModel?.action = routeToTakeProfitStopLossAction
        #endif
    }
}
