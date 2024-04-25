//
//  dydxTakeProfitStopLossViewPresenter.swift
//  dydxPresenters
//
//  Created by Michael Maguire on 4/1/24.
//

import dydxStateManager
import dydxViews
import ParticlesKit
import PlatformParticles
import PlatformUI
import RoutingKit
import Utilities
import PlatformRouting
import PanModal
import Combine
import Abacus
import dydxFormatter

public class dydxTakeProfitStopLossViewBuilder: NSObject, ObjectBuilderProtocol {
    public func build<T>() -> T? {
        let presenter = dydxTakeProfitStopLossViewPresenter()
        let view = presenter.viewModel?.createView() ?? PlatformViewModel().createView()
        return dydxTakeProfitStopLossViewController(presenter: presenter, view: view, configuration: .default) as? T
    }
}

private class dydxTakeProfitStopLossViewController: HostingViewController<PlatformView, dydxTakeProfitStopLossViewModel> {
    override public func arrive(to request: RoutingRequest?, animated: Bool) -> Bool {
        if request?.path == "/trade/take_profit_stop_loss", let marketId = parser.asString(request?.params?["marketId"]), let presenter = presenter as? dydxTakeProfitStopLossViewPresenter {
            AbacusStateManager.shared.setMarket(market: marketId)
            presenter.marketId = marketId
            return true
        }
        return false
    }
}

private protocol dydxTakeProfitStopLossViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxTakeProfitStopLossViewModel? { get }
}

private class dydxTakeProfitStopLossViewPresenter: HostedViewPresenter<dydxTakeProfitStopLossViewModel>, dydxTakeProfitStopLossViewPresenterProtocol {
    fileprivate var marketId: String?

    override func start() {
        super.start()

        clearTriggersInput()
        guard let marketId = marketId else { return }

        Publishers
            .CombineLatest3(AbacusStateManager.shared.state.selectedSubaccountPositions,
                           AbacusStateManager.shared.state.selectedSubaccountOrders,
                           AbacusStateManager.shared.state.configsAndAssetMap)
            .sink { [weak self] subaccountPositions, subaccountOrders, configsMap in
                self?.update(subaccountPositions: subaccountPositions, subaccountOrders: subaccountOrders, configsMap: configsMap)
            }
            .store(in: &subscriptions)

        AbacusStateManager.shared.state.market(of: marketId)
            .compactMap { $0 }
            .sink { [weak self] market in
                self?.update(market: market)
            }
            .store(in: &subscriptions)

        Publishers
            .CombineLatest3(
                AbacusStateManager.shared.state.triggerOrdersInput,
                AbacusStateManager.shared.state.validationErrors,
                AbacusStateManager.shared.state.configsAndAssetMap
            )
            .compactMap { $0 }
            .sink { [weak self] triggerOrdersInput, errors, configsMap in
                #if DEBUG
                if let triggerOrdersInput {
                    Console.shared.log("\nmmm marketId: \(triggerOrdersInput.marketId)")
                    Console.shared.log("mmm size: \(triggerOrdersInput.size)")
                    Console.shared.log("mmm stopLossOrder?.orderId: \(triggerOrdersInput.stopLossOrder?.orderId)")
                    Console.shared.log("mmm stopLossOrder?.size: \(triggerOrdersInput.stopLossOrder?.size?.doubleValue)")
                    Console.shared.log("mmm stopLossOrder?.side: \(triggerOrdersInput.stopLossOrder?.side?.rawValue)")
                    Console.shared.log("mmm stopLossOrder?.type: \(triggerOrdersInput.stopLossOrder?.type?.rawValue)\n")
                    Console.shared.log("mmm stopLossOrder?.price?.triggerPrice: \(triggerOrdersInput.stopLossOrder?.price?.triggerPrice)")
                    Console.shared.log("mmm stopLossOrder?.price?.limitPrice: \(triggerOrdersInput.stopLossOrder?.price?.limitPrice)")
                    Console.shared.log("mmm stopLossOrder?.price?.percentDiff: \(triggerOrdersInput.stopLossOrder?.price?.percentDiff)")
                    Console.shared.log("mmm stopLossOrder?.price?.usdcDiff: \(triggerOrdersInput.stopLossOrder?.price?.usdcDiff)")
                    Console.shared.log("mmm takeProfitOrder?.orderId: \(triggerOrdersInput.takeProfitOrder?.orderId)")
                    Console.shared.log("mmm takeProfitOrder?.size: \(triggerOrdersInput.takeProfitOrder?.size?.doubleValue)")
                    Console.shared.log("mmm takeProfitOrder?.side: \(triggerOrdersInput.takeProfitOrder?.side?.rawValue)\n")
                    Console.shared.log("mmm takeProfitOrder?.type: \(triggerOrdersInput.takeProfitOrder?.type?.rawValue)\n")
                    Console.shared.log("mmm takeProfitOrder?.price?.triggerPrice: \(triggerOrdersInput.takeProfitOrder?.price?.triggerPrice)")
                    Console.shared.log("mmm takeProfitOrder?.price?.limitPrice: \(triggerOrdersInput.takeProfitOrder?.price?.limitPrice)\n")
                    Console.shared.log("mmm takeProfitOrder?.price?.percentDiff: \(triggerOrdersInput.takeProfitOrder?.price?.percentDiff)")
                    Console.shared.log("mmm takeProfitOrder?.price?.usdcDiff: \(triggerOrdersInput.takeProfitOrder?.price?.usdcDiff)\n")
                }
                #endif
                self?.update(triggerOrdersInput: triggerOrdersInput, errors: errors, configsMap: configsMap)
            }
            .store(in: &subscriptions)
    }

    private func clearTriggersInput() {
        AbacusStateManager.shared.triggerOrders(input: nil, type: .marketid)
        AbacusStateManager.shared.triggerOrders(input: nil, type: .size)
        clearStopLossOrder()
        clearTakeProfitOrder()
    }

    private func clearStopLossOrder() {
        AbacusStateManager.shared.triggerOrders(input: nil, type: .stoplossorderid)
        AbacusStateManager.shared.triggerOrders(input: nil, type: .stoplossordersize)
        AbacusStateManager.shared.triggerOrders(input: nil, type: .stoplossordertype)
        AbacusStateManager.shared.triggerOrders(input: nil, type: .stoplosslimitprice)
        AbacusStateManager.shared.triggerOrders(input: nil, type: .stoplossprice)
        AbacusStateManager.shared.triggerOrders(input: nil, type: .stoplosspercentdiff)
        AbacusStateManager.shared.triggerOrders(input: nil, type: .stoplossusdcdiff)
    }

    private func clearTakeProfitOrder() {
        AbacusStateManager.shared.triggerOrders(input: nil, type: .takeprofitorderid)
        AbacusStateManager.shared.triggerOrders(input: nil, type: .takeprofitordersize)
        AbacusStateManager.shared.triggerOrders(input: nil, type: .takeprofitordertype)
        AbacusStateManager.shared.triggerOrders(input: nil, type: .takeprofitlimitprice)
        AbacusStateManager.shared.triggerOrders(input: nil, type: .takeprofitprice)
        AbacusStateManager.shared.triggerOrders(input: nil, type: .takeprofitpercentdiff)
        AbacusStateManager.shared.triggerOrders(input: nil, type: .takeprofitusdcdiff)
    }

    private func update(market: PerpetualMarket?) {
        viewModel?.oraclePrice = dydxFormatter.shared.raw(number: market?.oraclePrice?.doubleValue, digits: market?.configs?.displayTickSizeDecimals?.intValue ?? 2)
        viewModel?.customAmountViewModel?.assetId = market?.assetId
        viewModel?.customAmountViewModel?.stepSize = market?.configs?.stepSize?.stringValue
        viewModel?.customAmountViewModel?.minimumValue = market?.configs?.minOrderSize?.floatValue
    }

    private func update(triggerOrdersInput: TriggerOrdersInput?, errors: [ValidationError], configsMap: [String: MarketConfigsAndAsset]) {
        viewModel?.takeProfitStopLossInputAreaViewModel?.takeProfitAlert = nil
        viewModel?.takeProfitStopLossInputAreaViewModel?.stopLossAlert = nil
        viewModel?.customLimitPriceViewModel?.alert = nil

        if let error = errors.first {
            if let field = error.fields?.first {
                let alert = InlineAlertViewModel(.init(title: error.resources.title?.localizedString, body: error.resources.text?.localizedString, level: .error))
                switch field {
                case TriggerOrdersInputField.stoplossprice.rawValue, TriggerOrdersInputField.stoplossusdcdiff.rawValue, TriggerOrdersInputField.stoplosspercentdiff.rawValue:
                    viewModel?.takeProfitStopLossInputAreaViewModel?.stopLossAlert = alert
                case TriggerOrdersInputField.takeprofitprice.rawValue, TriggerOrdersInputField.takeprofitusdcdiff.rawValue, TriggerOrdersInputField.takeprofitpercentdiff.rawValue:
                    viewModel?.takeProfitStopLossInputAreaViewModel?.takeProfitAlert = alert
                case TriggerOrdersInputField.takeprofitlimitprice.rawValue, TriggerOrdersInputField.stoplosslimitprice.rawValue:
                    viewModel?.customLimitPriceViewModel?.alert = alert
                default:
                    break
                }
            }
        }

        // update displayed values
        let digits = configsMap[marketId ?? ""]?.configs?.displayTickSizeDecimals?.intValue ?? 2
        viewModel?.takeProfitStopLossInputAreaViewModel?.takeProfitPriceInputViewModel?.value = dydxFormatter.shared.raw(number: triggerOrdersInput?.takeProfitOrder?.price?.triggerPrice?.doubleValue, digits: digits)
        viewModel?.takeProfitStopLossInputAreaViewModel?.gainInputViewModel?.value = dydxFormatter.shared.raw(number: triggerOrdersInput?.takeProfitOrder?.price?.usdcDiff?.doubleValue, digits: 2)
        viewModel?.takeProfitStopLossInputAreaViewModel?.stopLossPriceInputViewModel?.value = dydxFormatter.shared.raw(number: triggerOrdersInput?.stopLossOrder?.price?.triggerPrice?.doubleValue, digits: digits)
        viewModel?.takeProfitStopLossInputAreaViewModel?.lossInputViewModel?.value = dydxFormatter.shared.raw(number: triggerOrdersInput?.stopLossOrder?.price?.usdcDiff?.doubleValue, digits: 2)

        viewModel?.customAmountViewModel?.value = triggerOrdersInput?.size?.doubleValue.magnitude.stringValue

        viewModel?.customLimitPriceViewModel?.takeProfitPriceInputViewModel?.value = triggerOrdersInput?.takeProfitOrder?.price?.limitPrice?.stringValue
        viewModel?.customLimitPriceViewModel?.stopLossPriceInputViewModel?.value = triggerOrdersInput?.stopLossOrder?.price?.limitPrice?.stringValue

        // update order types
        if let _ = triggerOrdersInput?.takeProfitOrder?.price?.limitPrice?.doubleValue {
            AbacusStateManager.shared.triggerOrders(input: Abacus.OrderType.takeprofitlimit.rawValue, type: .takeprofitordertype)
        } else {
            AbacusStateManager.shared.triggerOrders(input: Abacus.OrderType.takeprofitmarket.rawValue, type: .takeprofitordertype)
        }
        if let _ = triggerOrdersInput?.stopLossOrder?.price?.limitPrice?.doubleValue {
            AbacusStateManager.shared.triggerOrders(input: Abacus.OrderType.stoplimit.rawValue, type: .stoplossordertype)
        } else {
            AbacusStateManager.shared.triggerOrders(input: Abacus.OrderType.stopmarket.rawValue, type: .stoplossordertype)
        }

        if let error = errors.first {
            viewModel?.submissionReadiness = .fixErrors(cta: error.resources.action?.localizedString)
        } else if triggerOrdersInput?.takeProfitOrder?.price?.triggerPrice?.doubleValue == nil
            && triggerOrdersInput?.takeProfitOrder?.orderId == nil
            && triggerOrdersInput?.stopLossOrder?.price?.triggerPrice?.doubleValue == nil
            && triggerOrdersInput?.stopLossOrder?.orderId == nil {
            viewModel?.submissionReadiness = .needsInput
        } else {
            viewModel?.submissionReadiness = .readyToSubmit
        }
    }

    private func update(subaccountPositions: [SubaccountPosition], subaccountOrders: [SubaccountOrder], configsMap: [String: MarketConfigsAndAsset]) {
        // TODO: move this logic to abacus
        let position = subaccountPositions.first { subaccountPosition in
            subaccountPosition.id == marketId
        }
        let takeProfitOrders = subaccountOrders.filter { (order: SubaccountOrder) in
            order.marketId == marketId && (order.type == .takeprofitmarket || order.type == .takeprofitlimit) && order.side.opposite == position?.side.current && order.status == Abacus.OrderStatus.untriggered
        }
        let stopLossOrders = subaccountOrders.filter { (order: SubaccountOrder) in
            order.marketId == marketId && (order.type == .stopmarket || order.type == .stoplimit) && order.side.opposite == position?.side.current && order.status == Abacus.OrderStatus.untriggered
        }

        viewModel?.entryPrice = dydxFormatter.shared.raw(number: position?.entryPrice?.current?.doubleValue,
                                                         digits: configsMap[marketId ?? ""]?.configs?.displayTickSizeDecimals?.intValue ?? 2)

        viewModel?.takeProfitStopLossInputAreaViewModel?.numOpenTakeProfitOrders = takeProfitOrders.count
        viewModel?.takeProfitStopLossInputAreaViewModel?.numOpenStopLossOrders = stopLossOrders.count

        viewModel?.customAmountViewModel?.maximumValue = position?.size?.current?.floatValue.magnitude

        if takeProfitOrders.count == 1, stopLossOrders.count == 1,
            let takeProfitOrder = takeProfitOrders.first, let stopLossOrder = stopLossOrders.first {
            updateAbacusTriggerOrdersState(order: takeProfitOrder)
            updateAbacusTriggerOrdersState(order: stopLossOrder)
            // this separated logic is to figure out if custom amount should be set
            if takeProfitOrder.size == stopLossOrder.size, takeProfitOrder.size != position?.size?.current?.doubleValue {
                AbacusStateManager.shared.triggerOrders(input: takeProfitOrder.size.magnitude.stringValue, type: .size)
            }
        } else if takeProfitOrders.count == 1, let order = takeProfitOrders.first {
            updateAbacusTriggerOrdersState(order: order)
            // this separated logic is to figure out if custom amount should be set
            if order.size != position?.size?.current?.doubleValue {
                AbacusStateManager.shared.triggerOrders(input: order.size.magnitude.stringValue, type: .size)
            }
        } else if stopLossOrders.count == 1, let order = stopLossOrders.first {
            updateAbacusTriggerOrdersState(order: order)
            // this separated logic is to figure out if custom amount should be set
            if order.size != position?.size?.current?.doubleValue {
                AbacusStateManager.shared.triggerOrders(input: order.size.magnitude.stringValue, type: .size)
            }
        }

        AbacusStateManager.shared.triggerOrders(input: position?.size?.current?.stringValue, type: .size)
        AbacusStateManager.shared.triggerOrders(input: marketId, type: .marketid)

    }

    private func updateAbacusTriggerOrdersState(order: SubaccountOrder) {
        switch order.type {
        case .takeprofitlimit, .takeprofitmarket:
            AbacusStateManager.shared.triggerOrders(input: order.id, type: .takeprofitorderid)
            AbacusStateManager.shared.triggerOrders(input: order.size.magnitude.stringValue, type: .takeprofitordersize)
            AbacusStateManager.shared.triggerOrders(input: order.type.rawValue, type: .takeprofitordertype)
            AbacusStateManager.shared.triggerOrders(input: order.price.stringValue, type: .takeprofitlimitprice)
            AbacusStateManager.shared.triggerOrders(input: order.triggerPrice?.stringValue, type: .takeprofitprice)
        case .stoplimit, .stopmarket:
            AbacusStateManager.shared.triggerOrders(input: order.id, type: .stoplossorderid)
            AbacusStateManager.shared.triggerOrders(input: order.size.magnitude.stringValue, type: .stoplossordersize)
            AbacusStateManager.shared.triggerOrders(input: order.type.rawValue, type: .stoplossordertype)
            AbacusStateManager.shared.triggerOrders(input: order.price.stringValue, type: .stoplosslimitprice)
            AbacusStateManager.shared.triggerOrders(input: order.triggerPrice?.stringValue, type: .stoplossprice)
        default:
            assertionFailure("should not update from non trigger order")
        }
    }

    override init() {
        let viewModel = dydxTakeProfitStopLossViewModel()

        viewModel.takeProfitStopLossInputAreaViewModel = dydxTakeProfitStopLossInputAreaModel()
        viewModel.takeProfitStopLossInputAreaViewModel?.multipleOrdersExistViewModel = .init()
        viewModel.takeProfitStopLossInputAreaViewModel?.takeProfitPriceInputViewModel = .init(title: DataLocalizer.shared?.localize(path: "APP.TRIGGERS_MODAL.TP_PRICE", params: nil))
        viewModel.takeProfitStopLossInputAreaViewModel?.gainInputViewModel = .init(triggerType: .takeProfit)
        viewModel.takeProfitStopLossInputAreaViewModel?.stopLossPriceInputViewModel = .init(title: DataLocalizer.shared?.localize(path: "APP.TRIGGERS_MODAL.SL_PRICE", params: nil))
        viewModel.takeProfitStopLossInputAreaViewModel?.lossInputViewModel = .init(triggerType: .stopLoss)

        viewModel.customAmountViewModel = dydxCustomAmountViewModel()

        viewModel.customLimitPriceViewModel = dydxCustomLimitPriceViewModel()
        viewModel.customLimitPriceViewModel?.takeProfitPriceInputViewModel = .init(title: DataLocalizer.shared?.localize(path: "APP.TRIGGERS_MODAL.TP_LIMIT", params: nil))
        viewModel.customLimitPriceViewModel?.stopLossPriceInputViewModel = .init(title: DataLocalizer.shared?.localize(path: "APP.TRIGGERS_MODAL.SL_LIMIT", params: nil))

        super.init()

        // set up edit actions
        viewModel.takeProfitStopLossInputAreaViewModel?.takeProfitPriceInputViewModel?.onEdited = {
            AbacusStateManager.shared.triggerOrders(input: $0, type: .takeprofitprice)
        }
        viewModel.takeProfitStopLossInputAreaViewModel?.gainInputViewModel?.onEdited = {
            AbacusStateManager.shared.triggerOrders(input: $0, type: .takeprofitusdcdiff)
        }
        viewModel.takeProfitStopLossInputAreaViewModel?.stopLossPriceInputViewModel?.onEdited = {
            AbacusStateManager.shared.triggerOrders(input: $0, type: .stoplossprice)
        }
        viewModel.takeProfitStopLossInputAreaViewModel?.lossInputViewModel?.onEdited = {
            AbacusStateManager.shared.triggerOrders(input: $0, type: .stoplossusdcdiff)
        }
        viewModel.customAmountViewModel?.onEdited = {
            AbacusStateManager.shared.triggerOrders(input: $0, type: .size)
        }
        viewModel.customLimitPriceViewModel?.takeProfitPriceInputViewModel?.onEdited = {
            AbacusStateManager.shared.triggerOrders(input: $0, type: .takeprofitlimitprice)
        }
        viewModel.customLimitPriceViewModel?.stopLossPriceInputViewModel?.onEdited = {
            AbacusStateManager.shared.triggerOrders(input: $0, type: .stoplosslimitprice)
        }

        // set up toggle interactions
        viewModel.customAmountViewModel?.toggleAction = { _ in
            // if user is turning off, also set to nil
            // if user is turning on, can also set to nil
            // this is an abacus limitation since a "0" value created a validation error, would be bad UX
            AbacusStateManager.shared.triggerOrders(input: nil, type: .size)
        }
        viewModel.customLimitPriceViewModel?.toggleAction = { _ in
            // if user is turning off, also set to nil
            // if user is turning on, can also set to nil
            // this is an abacus limitation since a "0" value created a validation error, would be bad UX
            AbacusStateManager.shared.triggerOrders(input: nil, type: .takeprofitlimitprice)
            AbacusStateManager.shared.triggerOrders(input: nil, type: .stoplosslimitprice)
        }

        // set up button interactions
        viewModel.takeProfitStopLossInputAreaViewModel?.multipleOrdersExistViewModel?.viewAllAction = { [weak self] in
            guard let marketId = self?.marketId else { return }
            Router.shared?.navigate(to: .init(path: "/market",
                                              params: ["marketId": "\(marketId)",
                                                       "currentSection": "orders"]),
                                    animated: true,
                                    completion: nil)
        }
        viewModel.submissionAction = { [weak self] in
            self?.viewModel?.submissionReadiness = .submitting

            AbacusStateManager.shared.placeTriggerOrders { status in
                switch status {
                case .success:
                    // check self is not deinitialized, otherwise abacus may call callback more than once
                    guard let self = self else { return }
                    Router.shared?.navigate(to: .init(path: "/action/dismiss"), animated: true, completion: nil)
                case .failed(let error):
                    // TODO: how to handle errors?
                    self?.viewModel?.submissionReadiness = .fixErrors(cta: DataLocalizer.shared?.localize(path: "APP.GENERAL.UNKNOWN_ERROR", params: nil))
                }
            }
        }

        self.viewModel = viewModel
    }
}

private extension Abacus.OrderSide {
    var opposite: Abacus.PositionSide {
        switch self {
        case .buy: return .short_
        case .sell: return .long_
        default: return .short_
        }
    }
}
