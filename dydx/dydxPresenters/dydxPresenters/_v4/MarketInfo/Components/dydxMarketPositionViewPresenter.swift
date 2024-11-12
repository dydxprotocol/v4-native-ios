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
    @Published var pendingPosition: SubaccountPendingPosition?

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
            .CombineLatest3($pendingPosition,
                            AbacusStateManager.shared.state.marketMap,
                            AbacusStateManager.shared.state.assetMap)
            .sink { [weak self] pendingPosition, marketMap, assetMap in
                if let pendingPosition {
                    self?.viewModel?.pendingPosition = dydxPortfolioPositionsViewPresenter.createPendingPositionsViewModelItem(
                        pendingPosition: pendingPosition,
                        marketMap: marketMap,
                        assetMap: assetMap)
                } else {
                    self?.viewModel?.pendingPosition = nil
                }
            }
            .store(in: &subscriptions)

        Publishers
            .CombineLatest(AbacusStateManager.shared.state.onboarded,
                            $position.removeDuplicates())
            .sink { [weak self] (onboarded, position) in
                if !onboarded {
                    self?.viewModel?.emptyText = DataLocalizer.localize(path: "APP.GENERAL.PLACEHOLDER_NO_POSITIONS_LOG_IN")
                } else if position == nil {
                    self?.viewModel?.emptyText = DataLocalizer.localize(path: "APP.GENERAL.PLACEHOLDER_NO_POSITIONS")
                } else {
                    self?.viewModel?.emptyText = nil
                }
            }
            .store(in: &subscriptions)

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
        guard let sharedOrderViewModel = dydxPortfolioPositionsViewPresenter.createPositionViewModelItem(position: position, marketMap: marketMap, assetMap: assetMap) else {
            return
        }

        guard let market = marketMap[position.id], let configs = market.configs else {
            return
        }

        switch position.marginMode {
        case .isolated:
            viewModel?.editMarginAction = {
                let routingRequest = RoutingRequest(
                    path: "/trade/adjust_margin",
                    params: ["marketId": market.id,
                             "childSubaccountNumber": position.childSubaccountNumber?.stringValue as Any])
                Router.shared?.navigate(to: routingRequest,
                                        animated: true,
                                        completion: nil)
            }
        default:
            viewModel?.editMarginAction = nil
        }

        viewModel?.unrealizedPNLAmount = sharedOrderViewModel.unrealizedPnl
        viewModel?.unrealizedPNLPercent =  dydxFormatter.shared.percent(number: position.unrealizedPnlPercent.current?.doubleValue, digits: 2) ?? ""
        viewModel?.realizedPNLAmount = SignedAmountViewModel(amount: position.realizedPnl.current?.doubleValue, displayType: .dollar, coloringOption: .allText)

        if  let marginMode = position.marginMode {
            viewModel?.marginMode = DataLocalizer.shared?.localize(path: "APP.GENERAL.\(marginMode.rawValue.uppercased())", params: nil)
        }
        if let margin = position.marginValue.current?.doubleValue {
            viewModel?.margin = dydxFormatter.shared.dollar(number: NSNumber(value: margin), digits: 2)
        }

        viewModel?.liquidationPrice = dydxFormatter.shared.dollar(number: position.liquidationPrice.current?.doubleValue, digits: configs.displayTickSizeDecimals?.intValue ?? 0)

        viewModel?.leverage = sharedOrderViewModel.leverage
        viewModel?.leverageIcon = sharedOrderViewModel.leverageIcon
        viewModel?.size = sharedOrderViewModel.size
        viewModel?.side = SideTextViewModel(side: sharedOrderViewModel.sideText.side, coloringOption: .withBackground)
        viewModel?.token = sharedOrderViewModel.token
        viewModel?.logoUrl = sharedOrderViewModel.logoUrl
        viewModel?.gradientType = sharedOrderViewModel.gradientType

        viewModel?.amount = dydxFormatter.shared.dollar(number: position.notionalTotal.current?.doubleValue, digits: 2)

        viewModel?.openPrice = dydxFormatter.shared.dollar(number: position.entryPrice.current?.doubleValue, digits: configs.displayTickSizeDecimals?.intValue ?? 0)
        viewModel?.closePrice = dydxFormatter.shared.dollar(number: position.exitPrice?.doubleValue, digits: configs.displayTickSizeDecimals?.intValue ?? 0)

        viewModel?.funding = SignedAmountViewModel(amount: position.netFunding?.doubleValue, displayType: .dollar, coloringOption: .allText)

        let routeToTakeProfitStopLossAction = {[weak self] in
            if let marketId = self?.position?.id {
                Router.shared?.navigate(to: RoutingRequest(path: "/trade/take_profit_stop_loss", params: ["marketId": "\(marketId)"]), animated: true, completion: nil)
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
