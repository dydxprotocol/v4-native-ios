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
            if let marketId = self?.position?.id {
                Router.shared?.navigate(to: RoutingRequest(path: "/trade/close", params: ["marketId": "\(marketId)"]), animated: true, completion: nil)
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
        let routeToTakeProfitStopLossAction = {[weak self] in
            if let marketId = self?.position?.id {
                Router.shared?.navigate(to: RoutingRequest(path: "/trade/take_profit_stop_loss", params: ["marketId": "\(marketId)"]), animated: true, completion: nil)
            }
        }
        let routeToOrdersAction = {
            Router.shared?.navigate(to: RoutingRequest(path: "/market", params: ["currentSection": "orders"]), animated: true, completion: nil)
            return
        }

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
            let decimalDigits = market.configs?.tickSizeDecimals?.intValue ?? 0
            let stepSizeDecimals = market.configs?.stepSizeDecimals?.intValue ?? 0
            if takeProfitOrders.count > 1 {
                viewModel?.takeProfitStatusViewModel = .init(
                    triggerSide: .takeProfit,
                    triggerPriceText: DataLocalizer.shared?.localize(path: "APP.TRADE.MULTIPLE_ARROW", params: nil),
                    action: routeToOrdersAction)
            } else if let takeProfitOrder = takeProfitOrders.first {
                viewModel?.takeProfitStatusViewModel = .init(
                    triggerSide: .takeProfit,
                    triggerPriceText: dydxFormatter.shared.raw(number: takeProfitOrder.triggerPrice?.doubleValue, digits: decimalDigits),
                    limitPrice: takeProfitOrder.type == .takeprofitlimit ? dydxFormatter.shared.raw(number: takeProfitOrder.price, digits: decimalDigits) : nil,
                    amount: dydxFormatter.shared.raw(number: takeProfitOrder.size, digits: stepSizeDecimals),
                    action: routeToTakeProfitStopLossAction)
            } else {
                viewModel?.takeProfitStatusViewModel = .init(
                    triggerSide: .takeProfit,
                    action: routeToTakeProfitStopLossAction)
            }

            if stopLossOrders.count > 1 {
                viewModel?.stopLossStatusViewModel = .init(
                    triggerSide: .stopLoss,
                    triggerPriceText: DataLocalizer.shared?.localize(path: "APP.TRADE.MULTIPLE_ARROW", params: nil),
                    action: routeToOrdersAction)
            } else if let stopLossOrder = stopLossOrders.first {
                viewModel?.stopLossStatusViewModel = .init(
                    triggerSide: .stopLoss,
                    triggerPriceText: dydxFormatter.shared.raw(number: stopLossOrder.triggerPrice?.doubleValue, digits: decimalDigits),
                    limitPrice: stopLossOrder.type == .stoplimit ? dydxFormatter.shared.raw(number: stopLossOrder.price, digits: decimalDigits) : nil,
                    amount: dydxFormatter.shared.raw(number: stopLossOrder.size, digits: stepSizeDecimals),
                    action: routeToTakeProfitStopLossAction)
            } else {
                viewModel?.stopLossStatusViewModel = .init(
                    triggerSide: .stopLoss,
                    action: routeToTakeProfitStopLossAction)
            }
        }

        viewModel?.takeProfitStopLossAction = routeToTakeProfitStopLossAction
        #endif
    }
}
