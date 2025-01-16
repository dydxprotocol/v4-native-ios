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
        if request?.path == "/trade/take_profit_stop_loss",
           let marketId = parser.asString(request?.params?["marketId"]),
            let presenter = presenter as? dydxTakeProfitStopLossViewPresenter {
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
    fileprivate var marketId: String? {
        didSet {
            if marketId != oldValue {
                AbacusStateManager.shared.setMarket(market: marketId)
                AbacusStateManager.shared.resetTriggerOrders()
                AbacusStateManager.shared.triggerOrders(input: marketId, type: .marketid)
            }
        }
    }

    @SynchronizedLock private var pendingOrders: Int?

    override init() {
        let viewModel = dydxTakeProfitStopLossViewModel()

        viewModel.takeProfitStopLossInputAreaViewModel = dydxTakeProfitStopLossInputAreaModel()
        viewModel.takeProfitStopLossInputAreaViewModel?.multipleOrdersExistViewModel = .init()
        viewModel.takeProfitStopLossInputAreaViewModel?.takeProfitPriceInputViewModel = .init(title: DataLocalizer.shared?.localize(path: "APP.TRIGGERS_MODAL.TP_PRICE", params: nil))
        viewModel.takeProfitStopLossInputAreaViewModel?.stopLossPriceInputViewModel = .init(title: DataLocalizer.shared?.localize(path: "APP.TRIGGERS_MODAL.SL_PRICE", params: nil))

        viewModel.shouldDisplayCustomLimitPriceViewModel = AbacusStateManager.shared.environment?.featureFlags.isSlTpLimitOrdersEnabled == true

        viewModel.customAmountViewModel = dydxCustomAmountViewModel()

        viewModel.customLimitPriceViewModel = dydxCustomLimitPriceViewModel()
        viewModel.customLimitPriceViewModel?.takeProfitPriceInputViewModel = .init(title: DataLocalizer.shared?.localize(path: "APP.TRIGGERS_MODAL.TP_LIMIT", params: nil))
        viewModel.customLimitPriceViewModel?.stopLossPriceInputViewModel = .init(title: DataLocalizer.shared?.localize(path: "APP.TRIGGERS_MODAL.SL_LIMIT", params: nil))

        super.init()

        // set up edit actions
        viewModel.takeProfitStopLossInputAreaViewModel?.takeProfitPriceInputViewModel?.onEdited = {
            AbacusStateManager.shared.triggerOrders(input: $0, type: .takeprofitprice)
        }
        viewModel.takeProfitStopLossInputAreaViewModel?.stopLossPriceInputViewModel?.onEdited = {
            AbacusStateManager.shared.triggerOrders(input: $0, type: .stoplossprice)
        }
        viewModel.customAmountViewModel?.valuePublisher
            .removeDuplicates()
            .sink(receiveValue: { value in
                AbacusStateManager.shared.triggerOrders(input: value, type: .size)
            })
            .store(in: &subscriptions)

        viewModel.customLimitPriceViewModel?.takeProfitPriceInputViewModel?.onEdited = {
            AbacusStateManager.shared.triggerOrders(input: $0, type: .takeprofitlimitprice)
        }
        viewModel.customLimitPriceViewModel?.stopLossPriceInputViewModel?.onEdited = {
            AbacusStateManager.shared.triggerOrders(input: $0, type: .stoplosslimitprice)
        }
        viewModel.takeProfitStopLossInputAreaViewModel?.gainInputViewModel = .init(triggerType: .takeProfit) { (value, unit) in
            switch unit {
            case .dollars:
                AbacusStateManager.shared.triggerOrders(input: value, type: .takeprofitusdcdiff)
            case .percentage:
                AbacusStateManager.shared.triggerOrders(input: value, type: .takeprofitpercentdiff)
            }
        }
        viewModel.takeProfitStopLossInputAreaViewModel?.lossInputViewModel = .init(triggerType: .stopLoss) { (value, unit) in
            switch unit {
            case .dollars:
                AbacusStateManager.shared.triggerOrders(input: value, type: .stoplossusdcdiff)
            case .percentage:
                AbacusStateManager.shared.triggerOrders(input: value, type: .stoplosspercentdiff)
            }
        }

        viewModel.takeProfitStopLossInputAreaViewModel?.onClearTakeProfit = { [weak self] in
            self?.clearTakeProfitOrder()
        }
        viewModel.takeProfitStopLossInputAreaViewModel?.onClearStopLoss = { [weak self] in
            self?.clearStopLossOrder()
        }

        // set up toggle interactions
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

            self?.pendingOrders = AbacusStateManager.shared.placeTriggerOrders { status in
                switch status {
                case .success:
                    // check self is not deinitialized, otherwise abacus may call callback more than once
                    self?.pendingOrders? -= 1
                    if let pendingOrders = self?.pendingOrders, pendingOrders <= 0 {
                        Router.shared?.navigate(to: .init(path: "/action/dismiss"), animated: true, completion: nil)
                    }
                case .failed:
                    self?.pendingOrders = nil
                    self?.viewModel?.submissionReadiness = .fixErrors(cta: DataLocalizer.shared?.localize(path: "APP.GENERAL.UNKNOWN_ERROR", params: nil))
                }
            }
            // dismiss immediately if no changes
            if (self?.pendingOrders ?? 0) == 0 {
                Router.shared?.navigate(to: .init(path: "/action/dismiss"), animated: true, completion: nil)
            }
        }

        self.viewModel = viewModel
    }

    deinit {
        clearTriggersInput()
    }

    override func start() {
        super.start()

        guard let marketId = marketId else { return }

        let includeLimitOrders: Bool = AbacusStateManager.shared.environment?.featureFlags.isSlTpLimitOrdersEnabled == true

        Publishers
            .CombineLatest4(
                AbacusStateManager.shared.state.selectedSubaccountPositionOfMarket(marketId: marketId),
                AbacusStateManager.shared.state.takeProfitOrders(marketId: marketId, includeLimitOrders: includeLimitOrders),
                AbacusStateManager.shared.state.stopLossOrders(marketId: marketId, includeLimitOrders: includeLimitOrders),
                AbacusStateManager.shared.state.triggerOrdersInput
            )
            .sink { [weak self] position, takeProfitOrders, stopLossOrders, triggerOrdersInput in
                self?.updateAbacusTriggerOrder(position: position,
                                               takeProfitOrders: takeProfitOrders,
                                               stopLossOrders: stopLossOrders,
                                               triggerOrdersInput: triggerOrdersInput)
            }
            .store(in: &subscriptions)

        Publishers
            .CombineLatest(
                AbacusStateManager.shared.state.selectedSubaccountPositionOfMarket(marketId: marketId),
                AbacusStateManager.shared.state.configsAndAssetMap
            )
            .sink { [weak self] position, configsMap in
                self?.update(position: position, configsMap: configsMap)
            }
            .store(in: &subscriptions)

        Publishers
            .CombineLatest(
                AbacusStateManager.shared.state.market(of: marketId).compactMap { $0 },
                AbacusStateManager.shared.state.configsAndAssetMap
            )
            .sink { [weak self] market, configsMap in
                self?.update(market: market, configsMap: configsMap)
            }
            .store(in: &subscriptions)

        Publishers
            .CombineLatest4(
                AbacusStateManager.shared.state.triggerOrdersInput,
                AbacusStateManager.shared.state.validationErrors,
                AbacusStateManager.shared.state.takeProfitOrders(marketId: marketId, includeLimitOrders: includeLimitOrders),
                AbacusStateManager.shared.state.stopLossOrders(marketId: marketId, includeLimitOrders: includeLimitOrders)
            )
            .sink { [weak self] triggerOrdersInput, errors, takeProfitOrders, stopLossOrders in
                self?.updateErrorsAndCta(triggerOrdersInput: triggerOrdersInput, errors: errors, takeProfitOrders: takeProfitOrders, stopLossOrders: stopLossOrders)
            }
            .store(in: &subscriptions)

        Publishers
            .CombineLatest3(
                AbacusStateManager.shared.state.selectedSubaccountPositionOfMarket(marketId: marketId),
                AbacusStateManager.shared.state.triggerOrdersInput,
                AbacusStateManager.shared.state.configsAndAssetMap
            )
            .compactMap { $0 }
            .sink { [weak self] position, triggerOrdersInput, configsMap in
                self?.update(position: position, triggerOrdersInput: triggerOrdersInput, configsMap: configsMap)
            }
            .store(in: &subscriptions)
    }

    private func clearTriggersInput() {
        AbacusStateManager.shared.resetTriggerOrders()
        clearStopLossOrder()
        clearTakeProfitOrder()
    }

    private func clearStopLossOrder() {
        let types: [TriggerOrdersInputField] = [.stoplossordersize, .stoplossordertype, .stoplosslimitprice, .stoplossprice, .stoplosspercentdiff, .stoplossusdcdiff]
        for type in types {
            AbacusStateManager.shared.triggerOrders(input: nil, type: type)
        }
    }

    private func clearTakeProfitOrder() {
        let types: [TriggerOrdersInputField] = [.takeprofitordersize, .takeprofitordertype, .takeprofitlimitprice, .takeprofitprice, .takeprofitpercentdiff, .takeprofitusdcdiff]
        for type in types {
            AbacusStateManager.shared.triggerOrders(input: nil, type: type)
        }
    }

    private func update(market: PerpetualMarket, configsMap: [String: MarketConfigsAndAsset]) {
        let configs = configsMap[market.id]
        viewModel?.oraclePrice = dydxFormatter.shared.dollar(number: market.oraclePrice?.doubleValue, digits: market.configs?.displayTickSizeDecimals?.intValue ?? 2)
        viewModel?.customAmountViewModel?.sliderTextInput.accessoryTitle = configs?.asset?.displayableAssetId
        viewModel?.customAmountViewModel?.sliderTextInput.minValue = market.configs?.minOrderSize?.doubleValue.magnitude ?? 0
        // abacus stepSizeDecimals is not accurate for 10/100/1000 precision
        if let stepSize = market.configs?.stepSize?.doubleValue, stepSize > 0 {
            viewModel?.customAmountViewModel?.sliderTextInput.numberFormatter.fractionDigits = Int(-log10(stepSize))
        }
    }

    private func updateErrorsAndCta(
        triggerOrdersInput: TriggerOrdersInput?,
        errors: [ValidationError],
        takeProfitOrders: [SubaccountOrder],
        stopLossOrders: [SubaccountOrder]
    ) {
        viewModel?.takeProfitStopLossInputAreaViewModel?.takeProfitAlert = nil
        viewModel?.takeProfitStopLossInputAreaViewModel?.stopLossAlert = nil

        viewModel?.takeProfitStopLossInputAreaViewModel?.takeProfitPriceInputViewModel?.hasInputError = false
        viewModel?.takeProfitStopLossInputAreaViewModel?.stopLossPriceInputViewModel?.hasInputError = false

        viewModel?.customLimitPriceViewModel?.alert = nil

        if let error = errors.first {
            if let field = error.fields?.first {
                let alert = InlineAlertViewModel(.init(title: error.resources.title?.localizedString, body: error.resources.text?.localizedString, level: .error))
                switch field {
                case TriggerOrdersInputField.stoplossprice.rawValue, TriggerOrdersInputField.stoplossusdcdiff.rawValue, TriggerOrdersInputField.stoplosspercentdiff.rawValue:
                    viewModel?.takeProfitStopLossInputAreaViewModel?.stopLossPriceInputViewModel?.hasInputError = true
                    viewModel?.takeProfitStopLossInputAreaViewModel?.stopLossAlert = alert
                case TriggerOrdersInputField.takeprofitprice.rawValue, TriggerOrdersInputField.takeprofitusdcdiff.rawValue, TriggerOrdersInputField.takeprofitpercentdiff.rawValue:
                    viewModel?.takeProfitStopLossInputAreaViewModel?.takeProfitAlert = alert
                    viewModel?.takeProfitStopLossInputAreaViewModel?.takeProfitPriceInputViewModel?.hasInputError = true
                case TriggerOrdersInputField.takeprofitlimitprice.rawValue, TriggerOrdersInputField.stoplosslimitprice.rawValue:
                    viewModel?.customLimitPriceViewModel?.alert = alert
                default:
                    break
                }
            }
        }

        let isNewTriggerOrder = takeProfitOrders.count == 0 && stopLossOrders.count == 0
        let ctaString: String? = isNewTriggerOrder ?
            DataLocalizer.shared?.localize(path: "APP.TRADE.ADD_TRIGGERS", params: nil) :
            DataLocalizer.shared?.localize(path: "APP.TRADE.UPDATE_TRIGGERS", params: nil)

        if let error = errors.first {
            if let actionText = error.resources.action?.localizedString {
                viewModel?.submissionReadiness = .fixErrors(cta: actionText)
            } else {
                viewModel?.submissionReadiness = .needsInput(cta: ctaString)
            }
        } else if triggerOrdersInput?.takeProfitOrder?.price?.triggerPrice?.doubleValue == nil
            && triggerOrdersInput?.takeProfitOrder?.orderId == nil
            && triggerOrdersInput?.stopLossOrder?.price?.triggerPrice?.doubleValue == nil
            && triggerOrdersInput?.stopLossOrder?.orderId == nil {
            viewModel?.submissionReadiness = .needsInput(cta: ctaString)
        } else if pendingOrders ?? 0 > 0 {
            viewModel?.submissionReadiness = .submitting
        } else {
            viewModel?.submissionReadiness = .readyToSubmit(cta: ctaString)
        }
    }

    private func update(position: SubaccountPosition?,
                        triggerOrdersInput: TriggerOrdersInput?,
                        configsMap: [String: MarketConfigsAndAsset]
    ) {
        guard let marketConfig = configsMap[marketId ?? ""]?.configs else { return }

        // update displayed values
        let digits = marketConfig.displayTickSizeDecimals?.intValue ?? 2
        viewModel?.takeProfitStopLossInputAreaViewModel?.takeProfitPriceInputViewModel?.value = dydxFormatter.shared.raw(number: triggerOrdersInput?.takeProfitOrder?.price?.triggerPrice?.doubleValue, digits: digits)
        viewModel?.takeProfitStopLossInputAreaViewModel?.stopLossPriceInputViewModel?.value = dydxFormatter.shared.raw(number: triggerOrdersInput?.stopLossOrder?.price?.triggerPrice?.doubleValue, digits: digits)

        let formattedTakeProfitUsdcDiff = dydxFormatter.shared.raw(number: triggerOrdersInput?.takeProfitOrder?.price?.usdcDiff?.doubleValue, digits: 2) ?? ""
        let formattedTakeProfitUsdcPercentage = dydxFormatter.shared.raw(number: triggerOrdersInput?.takeProfitOrder?.price?.percentDiff?.doubleValue, digits: 2) ?? ""
        viewModel?.takeProfitStopLossInputAreaViewModel?.gainInputViewModel?.set(value: formattedTakeProfitUsdcDiff, forUnit: .dollars)
        viewModel?.takeProfitStopLossInputAreaViewModel?.gainInputViewModel?.set(value: formattedTakeProfitUsdcPercentage, forUnit: .percentage)

        let formattedStopLossUsdcDiff = dydxFormatter.shared.raw(number: triggerOrdersInput?.stopLossOrder?.price?.usdcDiff?.doubleValue, digits: 2) ?? ""
        let formattedStopLossUsdcPercentage = dydxFormatter.shared.raw(number: triggerOrdersInput?.stopLossOrder?.price?.percentDiff?.doubleValue, digits: 2) ?? ""
        viewModel?.takeProfitStopLossInputAreaViewModel?.lossInputViewModel?.set(value: formattedStopLossUsdcDiff, forUnit: .dollars)
        viewModel?.takeProfitStopLossInputAreaViewModel?.lossInputViewModel?.set(value: formattedStopLossUsdcPercentage, forUnit: .percentage)

        // logic primarily to pre-populate custom amount.
        // we do not want to turn on custom amount if it is not already on and the order size is the same amount as the position size. The custom amount may already be on if user manually turned it on, or a pre-existing custom amount exists that is less than the position size
        if let customSize = triggerOrdersInput?.size?.doubleValue.magnitude, customSize != position?.size.current?.doubleValue.magnitude || viewModel?.customAmountViewModel?.isOn == true {
            viewModel?.customAmountViewModel?.isOn = true
            viewModel?.customAmountViewModel?.sliderTextInput.value = customSize
        }

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
    }

    private func update(position: SubaccountPosition?, configsMap: [String: MarketConfigsAndAsset]) {
        guard let marketConfig = configsMap[marketId ?? ""]?.configs else { return }

        viewModel?.entryPrice = dydxFormatter.shared.dollar(number: position?.entryPrice.current?.doubleValue,
                                                         digits: marketConfig.displayTickSizeDecimals?.intValue ?? 2)
        viewModel?.customAmountViewModel?.sliderTextInput.maxValue = position?.size.current?.doubleValue.magnitude ?? 0

        // update toggle interaction, must do it within position listener update method since it depends on market config min order size
        viewModel?.customAmountViewModel?.toggleAction = { isOn in
            if isOn {
                // start at min amount
                AbacusStateManager.shared.triggerOrders(input: marketConfig.minOrderSize?.stringValue, type: .size)
            } else {
                AbacusStateManager.shared.triggerOrders(input: position?.size.current?.doubleValue.magnitude.stringValue, type: .size)
            }
        }
    }

    private func updateAbacusTriggerOrder(
        position: SubaccountPosition?,
        takeProfitOrders: [SubaccountOrder],
        stopLossOrders: [SubaccountOrder],
        triggerOrdersInput: TriggerOrdersInput?
    ) {
        viewModel?.takeProfitStopLossInputAreaViewModel?.numOpenTakeProfitOrders = takeProfitOrders.count
        viewModel?.takeProfitStopLossInputAreaViewModel?.numOpenStopLossOrders = stopLossOrders.count
        let takeProfitOrderSize = takeProfitOrders.first?.size ?? 0.0
        let stopLossOrderSize = stopLossOrders.first?.size ?? 0.0

        let takeProfitOrder: SubaccountOrder?
        if takeProfitOrders.count == 1 {
            takeProfitOrder = takeProfitOrders[0]
        } else {
            takeProfitOrder = nil
        }

        let stopLessOrder: SubaccountOrder?
        if stopLossOrders.count == 1 {
            stopLessOrder = stopLossOrders[0]
        } else {
            stopLessOrder = nil
        }

        if triggerOrdersInput?.takeProfitOrder?.orderId == nil, let takeProfitOrder = takeProfitOrder {
            updateAbacusTriggerOrdersState(order: takeProfitOrder)
        }
        if triggerOrdersInput?.stopLossOrder?.orderId == nil, let stopLessOrder = stopLessOrder {
            updateAbacusTriggerOrdersState(order: stopLessOrder)
        }

        // set default order type
        if takeProfitOrders.count == 0, triggerOrdersInput?.takeProfitOrder?.type == nil {
            AbacusStateManager.shared.triggerOrders(input: Abacus.OrderType.takeprofitmarket.rawValue,
                                                    type: TriggerOrdersInputField.takeprofitordertype)
        }
        if stopLossOrders.count == 0, triggerOrdersInput?.stopLossOrder?.type == nil {
            AbacusStateManager.shared.triggerOrders(input: Abacus.OrderType.stopmarket.rawValue,
                                                    type: TriggerOrdersInputField.stoplossordertype)
        }

        // size
        if triggerOrdersInput?.size == nil {
            if takeProfitOrderSize == 0.0 && stopLossOrderSize == 0.0 {
                // defaulting to position size
                let size: String?
                if let positionSize = position?.size.current?.doubleValue {
                    size = "\(positionSize)"
                } else {
                    size = nil
                }
                AbacusStateManager.shared.triggerOrders(input: size,
                                                        type: TriggerOrdersInputField.size)
            } else if takeProfitOrderSize > 0.0 && stopLossOrderSize > 0.0 && takeProfitOrderSize != stopLossOrderSize {
                // different order size
                AbacusStateManager.shared.triggerOrders(input: nil,
                                                        type: TriggerOrdersInputField.size)
            } else if takeProfitOrderSize > 0.0 {
                AbacusStateManager.shared.triggerOrders(input: "\(takeProfitOrderSize)",
                                                        type: TriggerOrdersInputField.size)
            } else if stopLossOrderSize > 0.0 {
                AbacusStateManager.shared.triggerOrders(input: "\(stopLossOrderSize)",
                                                        type: TriggerOrdersInputField.size)
            }
        }
    }

    private func updateAbacusTriggerOrdersState(order: SubaccountOrder) {
        switch order.type {
        case .takeprofitlimit, .takeprofitmarket:
            AbacusStateManager.shared.triggerOrders(input: order.id, type: .takeprofitorderid)
            AbacusStateManager.shared.triggerOrders(input: order.size.magnitude.stringValue, type: .takeprofitordersize)
            AbacusStateManager.shared.triggerOrders(input: order.type.rawValue, type: .takeprofitordertype)
            if order.type == .takeprofitlimit {
                AbacusStateManager.shared.triggerOrders(input: order.price.stringValue, type: .takeprofitlimitprice)
            }
            AbacusStateManager.shared.triggerOrders(input: order.triggerPrice?.stringValue, type: .takeprofitprice)
        case .stoplimit, .stopmarket:
            AbacusStateManager.shared.triggerOrders(input: order.id, type: .stoplossorderid)
            AbacusStateManager.shared.triggerOrders(input: order.size.magnitude.stringValue, type: .stoplossordersize)
            AbacusStateManager.shared.triggerOrders(input: order.type.rawValue, type: .stoplossordertype)
            if order.type == .stoplimit {
                AbacusStateManager.shared.triggerOrders(input: order.price.stringValue, type: .stoplosslimitprice)
            }
            AbacusStateManager.shared.triggerOrders(input: order.triggerPrice?.stringValue, type: .stoplossprice)
        default:
            assertionFailure("should not update from non trigger order")
        }
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
