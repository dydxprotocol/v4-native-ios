//
//  dydxMarketTpSlGroupViewPresenter.swift
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

protocol dydxMarketTpSlGroupViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxMarketTpSlGroupViewModel? { get }
}

class dydxMarketTpSlGroupViewPresenter: HostedViewPresenter<dydxMarketTpSlGroupViewModel>, dydxMarketTpSlGroupViewPresenterProtocol {
    @Published var position: SubaccountPosition?

    override init() {
        super.init()

        viewModel = dydxMarketTpSlGroupViewModel()
    }

    override func start() {
        super.start()

        Publishers
            .CombineLatest4($position.compactMap { $0 }.removeDuplicates(),
                            AbacusStateManager.shared.state.selectedSubaccountTriggerOrders,
                            AbacusStateManager.shared.state.marketMap,
                            AbacusStateManager.shared.state.assetMap)
            .sink { [weak self] position, triggerOrders, marketMap, assetMap in
                self?.updatePosition(position: position, triggerOrders: triggerOrders, marketMap: marketMap, assetMap: assetMap)
            }
            .store(in: &subscriptions)
    }

    private func updatePosition(position: SubaccountPosition, triggerOrders: [SubaccountOrder], marketMap: [String: PerpetualMarket], assetMap: [String: Asset]) {
        guard let market = marketMap[position.id] else {
            return
        }

        let routeToTakeProfitStopLossAction = {[weak self] in
            if let marketId = self?.position?.id {
                Router.shared?.navigate(to: RoutingRequest(path: "/trade/take_profit_stop_loss", params: ["marketId": marketId]), animated: true, completion: nil)
            }
        }
        let routeToOrdersAction = {
            Router.shared?.navigate(to: RoutingRequest(path: "/market", params: ["currentSection": "orders"]), animated: true, completion: nil)
            return
        }

        let takeProfitOrders = triggerOrders.filter { (order: SubaccountOrder) in
            order.marketId == position.id
            && (order.type == .takeprofitmarket || (order.type == .takeprofitlimit && AbacusStateManager.shared.environment?.featureFlags.isSlTpLimitOrdersEnabled == true))
            && order.side.opposite == position.side.current
        }
        let stopLossOrders = triggerOrders.filter { (order: SubaccountOrder) in
            order.marketId == position.id
            && (order.type == .stopmarket || (order.type == .stoplimit && AbacusStateManager.shared.environment?.featureFlags.isSlTpLimitOrdersEnabled == true))
            && order.side.opposite == position.side.current
        }
        if takeProfitOrders.isEmpty && stopLossOrders.isEmpty {
            viewModel?.takeProfitStatusViewModel = nil
            viewModel?.stopLossStatusViewModel = nil
        } else {
            let decimalDigits = market.configs?.tickSizeDecimals?.intValue ?? 0
            if takeProfitOrders.count > 1 {
                viewModel?.takeProfitStatusViewModel = .init(
                    triggerSide: .takeProfit,
                    triggerPriceText: DataLocalizer.shared?.localize(path: "APP.TRADE.MULTIPLE_ARROW", params: nil),
                    action: routeToOrdersAction)
            } else if let takeProfitOrder = takeProfitOrders.first, let positionSize = position.size.current?.doubleValue.magnitude {
                let orderSize = takeProfitOrder.size.magnitude
                viewModel?.takeProfitStatusViewModel = .init(
                    triggerSide: .takeProfit,
                    triggerPriceText: dydxFormatter.shared.dollar(number: takeProfitOrder.triggerPrice?.doubleValue, digits: decimalDigits),
                    limitPrice: takeProfitOrder.type == .takeprofitlimit ? dydxFormatter.shared.dollar(number: takeProfitOrder.price, digits: decimalDigits) : nil,
                    amount: positionSize == orderSize && positionSize > 0 ? nil : dydxFormatter.shared.percent(number: orderSize / positionSize, digits: 2),
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
            } else if let stopLossOrder = stopLossOrders.first, let positionSize = position.size.current?.doubleValue.magnitude {
                let orderSize = stopLossOrder.size.magnitude
                viewModel?.stopLossStatusViewModel = .init(
                    triggerSide: .stopLoss,
                    triggerPriceText: dydxFormatter.shared.dollar(number: stopLossOrder.triggerPrice?.doubleValue, digits: decimalDigits),
                    limitPrice: stopLossOrder.type == .stoplimit ? dydxFormatter.shared.dollar(number: stopLossOrder.price, digits: decimalDigits) : nil,
                    // don't show amount unless order size is custom
                    amount: positionSize == orderSize && positionSize > 0 ? nil : dydxFormatter.shared.percent(number: orderSize / positionSize, digits: 2),
                    action: routeToTakeProfitStopLossAction)
            } else {
                viewModel?.stopLossStatusViewModel = .init(
                    triggerSide: .stopLoss,
                    action: routeToTakeProfitStopLossAction)
            }
        }

        viewModel?.takeProfitStopLossAction = routeToTakeProfitStopLossAction
    }

}
