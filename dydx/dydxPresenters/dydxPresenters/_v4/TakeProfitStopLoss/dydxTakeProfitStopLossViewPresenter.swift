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
    @SynchronizedLock private var pendingOrders: Int?

    deinit {
        clearTriggersInput()
    }

    override func start() {
        super.start()

        guard let marketId = marketId else { return }
        AbacusStateManager.shared.triggerOrders(input: marketId, type: .marketid)

        Publishers
            // note we use a zip here intentionally so that the user input is not overwritten unless triggerOrders updates
            // which should not really happen unless the active trigger order(s) get triggered or they are placed simultaneously
            // on another platform
            .Zip(AbacusStateManager.shared.state.selectedSubaccountPositions,
                 AbacusStateManager.shared.state.selectedSubaccountTriggerOrders)
            .sink { [weak self] subaccountPositions, triggerOrders in
                self?.update(subaccountPositions: subaccountPositions, triggerOrders: triggerOrders)
            }
            .store(in: &subscriptions)

        Publishers
            .CombineLatest(AbacusStateManager.shared.state.selectedSubaccountPositions,
                           AbacusStateManager.shared.state.configsAndAssetMap)
            .sink { [weak self] subaccountPositions, configsMap in
                self?.update(subaccountPositions: subaccountPositions, configsMap: configsMap)
            }
            .store(in: &subscriptions)

        AbacusStateManager.shared.state.market(of: marketId)
            .compactMap { $0 }
            .sink { [weak self] market in
                self?.update(market: market)
            }
            .store(in: &subscriptions)

        Publishers
            .CombineLatest4(
                AbacusStateManager.shared.state.selectedSubaccountPositions,
                AbacusStateManager.shared.state.triggerOrdersInput,
                AbacusStateManager.shared.state.validationErrors,
                AbacusStateManager.shared.state.configsAndAssetMap
            )
            .compactMap { $0 }
            .sink { [weak self] subaccountPositions, triggerOrdersInput, errors, configsMap in
                self?.update(subaccountPositions: subaccountPositions, triggerOrdersInput: triggerOrdersInput, errors: errors, configsMap: configsMap)
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
        viewModel?.oraclePrice = dydxFormatter.shared.dollar(number: market?.oraclePrice?.doubleValue, digits: market?.configs?.displayTickSizeDecimals?.intValue ?? 2)
        viewModel?.customAmountViewModel?.sliderTextInput.accessoryTitle = market?.assetId
        viewModel?.customAmountViewModel?.sliderTextInput.minValue = market?.configs?.minOrderSize?.doubleValue.magnitude ?? 0
        // abacus stepSizeDecimals is not accurate for 10/100/1000 precision
        if let stepSize = market?.configs?.stepSize?.doubleValue, stepSize > 0 {
            viewModel?.customAmountViewModel?.sliderTextInput.numberFormatter.fractionDigits = Int(-log10(stepSize))
        }
    }

    private func update(subaccountPositions: [SubaccountPosition], triggerOrdersInput: TriggerOrdersInput?, errors: [ValidationError], configsMap: [String: MarketConfigsAndAsset]) {
        guard let marketConfig = configsMap[marketId ?? ""]?.configs else { return }

        let position = subaccountPositions.first { subaccountPosition in
            subaccountPosition.id == marketId
        }

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

        if let error = errors.first {
            if let actionText = error.resources.action?.localizedString {
                viewModel?.submissionReadiness = .fixErrors(cta: actionText)
            } else {
                viewModel?.submissionReadiness = .needsInput
            }
        } else if triggerOrdersInput?.takeProfitOrder?.price?.triggerPrice?.doubleValue == nil
            && triggerOrdersInput?.takeProfitOrder?.orderId == nil
            && triggerOrdersInput?.stopLossOrder?.price?.triggerPrice?.doubleValue == nil
            && triggerOrdersInput?.stopLossOrder?.orderId == nil {
            viewModel?.submissionReadiness = .needsInput
        } else if pendingOrders ?? 0 > 0 {
            viewModel?.submissionReadiness = .submitting
        } else {
            viewModel?.submissionReadiness = .readyToSubmit
        }
    }

    private func update(subaccountPositions: [SubaccountPosition], configsMap: [String: MarketConfigsAndAsset]) {
        guard let marketConfig = configsMap[marketId ?? ""]?.configs else { return }
        let position = subaccountPositions.first { subaccountPosition in
            subaccountPosition.id == marketId
        }
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

    private func update(subaccountPositions: [SubaccountPosition], triggerOrders: [SubaccountOrder]) {
        let position = subaccountPositions.first { subaccountPosition in
            subaccountPosition.id == marketId
        }
        let takeProfitOrders = triggerOrders.filter { (order: SubaccountOrder) in
            order.marketId == marketId
            && (order.type == .takeprofitmarket || (order.type == .takeprofitlimit && AbacusStateManager.shared.environment?.featureFlags.isSlTpLimitOrdersEnabled == true))
            && order.side.opposite == position?.side.current
        }
        let stopLossOrders = triggerOrders.filter { (order: SubaccountOrder) in
            order.marketId == marketId
            && (order.type == .stopmarket || (order.type == .stoplimit && AbacusStateManager.shared.environment?.featureFlags.isSlTpLimitOrdersEnabled == true))
            && order.side.opposite == position?.side.current
        }

        viewModel?.takeProfitStopLossInputAreaViewModel?.numOpenTakeProfitOrders = takeProfitOrders.count
        viewModel?.takeProfitStopLossInputAreaViewModel?.numOpenStopLossOrders = stopLossOrders.count

        if takeProfitOrders.count == 1, stopLossOrders.count == 1,
            let takeProfitOrder = takeProfitOrders.first, let stopLossOrder = stopLossOrders.first {
            updateAbacusTriggerOrdersState(order: takeProfitOrder)
            updateAbacusTriggerOrdersState(order: stopLossOrder)
            // this separated logic is to figure out if custom amount should be set
            if takeProfitOrder.size == stopLossOrder.size, takeProfitOrder.size != position?.size.current?.doubleValue.magnitude {
                AbacusStateManager.shared.triggerOrders(input: takeProfitOrder.size.magnitude.stringValue, type: .size)
            }
        } else if takeProfitOrders.count == 1, let order = takeProfitOrders.first {
            updateAbacusTriggerOrdersState(order: order)
            // this separated logic is to figure out if custom amount should be set
            if order.size.magnitude != position?.size.current?.doubleValue.magnitude, order.size != position?.size.current?.doubleValue.magnitude {
                AbacusStateManager.shared.triggerOrders(input: order.size.magnitude.stringValue, type: .size)
            }
        } else if stopLossOrders.count == 1, let order = stopLossOrders.first {
            updateAbacusTriggerOrdersState(order: order)
            // this separated logic is to figure out if custom amount should be set
            if order.size.magnitude != position?.size.current?.doubleValue.magnitude, order.size != position?.size.current?.doubleValue.magnitude {
                AbacusStateManager.shared.triggerOrders(input: order.size.magnitude.stringValue, type: .size)
            }
        } else {
            AbacusStateManager.shared.triggerOrders(input: position?.size.current?.doubleValue.magnitude.stringValue, type: .takeprofitordersize)
            AbacusStateManager.shared.triggerOrders(input: position?.size.current?.doubleValue.magnitude.stringValue, type: .stoplossordersize)
        }
    }

    private func updateAbacusTriggerOrdersState(order: SubaccountOrder) {
        switch order.type {
        case .takeprofitlimit, .takeprofitmarket:
            if AbacusStateManager.shared.environment?.featureFlags.isSlTpLimitOrdersEnabled == false && order.type == .takeprofitlimit {
                return
            }
            AbacusStateManager.shared.triggerOrders(input: order.id, type: .takeprofitorderid)
            AbacusStateManager.shared.triggerOrders(input: order.size.magnitude.stringValue, type: .takeprofitordersize)
            AbacusStateManager.shared.triggerOrders(input: order.type.rawValue, type: .takeprofitordertype)
            if order.type == .takeprofitlimit {
                AbacusStateManager.shared.triggerOrders(input: order.price.stringValue, type: .takeprofitlimitprice)
            }
            AbacusStateManager.shared.triggerOrders(input: order.triggerPrice?.stringValue, type: .takeprofitprice)
        case .stoplimit, .stopmarket:
            if AbacusStateManager.shared.environment?.featureFlags.isSlTpLimitOrdersEnabled == false && order.type == .stoplimit {
                return
            }
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
