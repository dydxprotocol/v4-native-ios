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
        let configuration = HostingViewControllerConfiguration(fixedHeight: UIScreen.main.bounds.height)
        return dydxTakeProfitStopLossViewController(presenter: presenter, view: view, configuration: configuration) as? T
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
            .CombineLatest(AbacusStateManager.shared.state.selectedSubaccountPositions,
                 AbacusStateManager.shared.state.selectedSubaccountOrders)
            .removeAllDuplicates(by: { v1, v2 in
                v1.0.count == v2.0.count && v1.1.count == v2.1.count
            })
            .sink { [weak self] subaccountPositions, subaccountOrders in
                self?.update(subaccountPositions: subaccountPositions, subaccountOrders: subaccountOrders)
            }
            .store(in: &subscriptions)

        AbacusStateManager.shared.state.market(of: marketId)
            .compactMap { $0 }
            .sink { [weak self] market in
                self?.update(market: market)
            }
            .store(in: &subscriptions)

        Publishers
            .CombineLatest(
                AbacusStateManager.shared.state.triggerOrdersInput,
                AbacusStateManager.shared.state.validationErrors
            )
            .compactMap { $0 }
            .sink { [weak self] triggerOrdersInput, errors in
                #if DEBUG
                if let triggerOrdersInput {
                    Console.shared.log("\nmmm marketId: \(triggerOrdersInput.marketId)")
                    Console.shared.log("mmm size: \(triggerOrdersInput.size)")
                    Console.shared.log("mmm stopLossOrder?.orderId: \(triggerOrdersInput.stopLossOrder?.orderId)")
                    Console.shared.log("mmm stopLossOrder?.size: \(triggerOrdersInput.stopLossOrder?.size?.doubleValue)")
                    Console.shared.log("mmm stopLossOrder?.side: \(triggerOrdersInput.stopLossOrder?.side?.rawValue)")
                    Console.shared.log("mmm stopLossOrder?.type: \(triggerOrdersInput.stopLossOrder?.type?.rawValue)\n")
                    Console.shared.log("mmm stopLossOrder?.price?.triggerPrice: \(triggerOrdersInput.stopLossOrder?.price?.triggerPrice)")
                    Console.shared.log("mmm stopLossOrder?.price?.percentDiff: \(triggerOrdersInput.stopLossOrder?.price?.percentDiff)")
                    Console.shared.log("mmm stopLossOrder?.price?.usdcDiff: \(triggerOrdersInput.stopLossOrder?.price?.usdcDiff)")
                    Console.shared.log("mmm takeProfitOrder?.orderId: \(triggerOrdersInput.takeProfitOrder?.orderId)")
                    Console.shared.log("mmm takeProfitOrder?.size: \(triggerOrdersInput.takeProfitOrder?.size?.doubleValue)")
                    Console.shared.log("mmm takeProfitOrder?.side: \(triggerOrdersInput.takeProfitOrder?.side?.rawValue)\n")
                    Console.shared.log("mmm takeProfitOrder?.type: \(triggerOrdersInput.takeProfitOrder?.type?.rawValue)\n")
                    Console.shared.log("mmm takeProfitOrder?.price?.triggerPrice: \(triggerOrdersInput.takeProfitOrder?.price?.triggerPrice)")
                    Console.shared.log("mmm takeProfitOrder?.price?.percentDiff: \(triggerOrdersInput.takeProfitOrder?.price?.percentDiff)")
                    Console.shared.log("mmm takeProfitOrder?.price?.usdcDiff: \(triggerOrdersInput.takeProfitOrder?.price?.usdcDiff)\n")
                }
                #endif
                self?.update(triggerOrdersInput: triggerOrdersInput, errors: errors)
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
        viewModel?.oraclePrice = market?.oraclePrice?.doubleValue
    }

    private func update(triggerOrdersInput: TriggerOrdersInput?, errors: [ValidationError]) {

        viewModel?.takeProfitStopLossInputAreaViewModel?.takeProfitAlert = nil
        viewModel?.takeProfitStopLossInputAreaViewModel?.stopLossAlert = nil

        for error in errors {
            let alert = InlineAlertViewModel(.init(title: error.resources.title?.localized, body: error.resources.text?.localized, level: .error))
            switch error.code {
            case "TRIGGER_MUST_ABOVE_INDEX_PRICE":
                print("mmm: \(error)")
                if triggerOrdersInput?.stopLossOrder?.side == .buy {
                    viewModel?.takeProfitStopLossInputAreaViewModel?.stopLossAlert = alert
                }
                if triggerOrdersInput?.takeProfitOrder?.side == .sell {
                    viewModel?.takeProfitStopLossInputAreaViewModel?.takeProfitAlert = alert
                }
            case "TRIGGER_MUST_BELOW_INDEX_PRICE":
                print("mmm: \(error)")
                if triggerOrdersInput?.stopLossOrder?.side == .sell {
                    viewModel?.takeProfitStopLossInputAreaViewModel?.stopLossAlert = alert
                }
                if triggerOrdersInput?.takeProfitOrder?.side == .buy {
                    viewModel?.takeProfitStopLossInputAreaViewModel?.takeProfitAlert = alert
                }
            case "USER_MAX_ORDERS":
                if triggerOrdersInput?.stopLossOrder?.price?.triggerPrice != nil {
                    viewModel?.takeProfitStopLossInputAreaViewModel?.stopLossAlert = alert
                }
                if triggerOrdersInput?.takeProfitOrder?.price?.triggerPrice != nil {
                    viewModel?.takeProfitStopLossInputAreaViewModel?.takeProfitAlert = alert
                }
            default:
                print("mmm: ", error.code)
            }
        }

        // update displayed values
        viewModel?.takeProfitStopLossInputAreaViewModel?.takeProfitPriceInputViewModel?.value = dydxFormatter.shared.raw(number: triggerOrdersInput?.takeProfitOrder?.price?.triggerPrice?.doubleValue, digits: 2)
        viewModel?.takeProfitStopLossInputAreaViewModel?.gainInputViewModel?.value = dydxFormatter.shared.raw(number: triggerOrdersInput?.takeProfitOrder?.price?.usdcDiff?.doubleValue, digits: 2)
        viewModel?.takeProfitStopLossInputAreaViewModel?.stopLossPriceInputViewModel?.value = dydxFormatter.shared.raw(number: triggerOrdersInput?.stopLossOrder?.price?.triggerPrice?.doubleValue, digits: 2)
        viewModel?.takeProfitStopLossInputAreaViewModel?.lossInputViewModel?.value = dydxFormatter.shared.raw(number: triggerOrdersInput?.stopLossOrder?.price?.usdcDiff?.doubleValue, digits: 2)

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
            viewModel?.submissionReadiness = .fixErrors(cta: error.resources.action?.localized)
        } else if triggerOrdersInput?.takeProfitOrder?.price?.triggerPrice?.doubleValue == nil
            && triggerOrdersInput?.takeProfitOrder?.orderId == nil
            && triggerOrdersInput?.stopLossOrder?.price?.triggerPrice?.doubleValue == nil
            && triggerOrdersInput?.stopLossOrder?.orderId == nil {
            viewModel?.submissionReadiness = .needsInput
        } else {
            viewModel?.submissionReadiness = .readyToSubmit
        }
    }

    private func update(subaccountPositions: [SubaccountPosition], subaccountOrders: [SubaccountOrder]) {
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

        viewModel?.entryPrice = position?.entryPrice?.current?.doubleValue

        viewModel?.takeProfitStopLossInputAreaViewModel?.numOpenTakeProfitOrders = takeProfitOrders.count
        viewModel?.takeProfitStopLossInputAreaViewModel?.numOpenStopLossOrders = stopLossOrders.count

        if takeProfitOrders.count == 1, let order = takeProfitOrders.first {
            AbacusStateManager.shared.triggerOrders(input: order.id, type: .takeprofitorderid)
            AbacusStateManager.shared.triggerOrders(input: order.size.description, type: .takeprofitordersize)
            AbacusStateManager.shared.triggerOrders(input: order.type.rawValue, type: .takeprofitordertype)
            AbacusStateManager.shared.triggerOrders(input: order.price.description, type: .takeprofitlimitprice)
            AbacusStateManager.shared.triggerOrders(input: order.triggerPrice?.stringValue, type: .takeprofitprice)
        }
        if stopLossOrders.count == 1, let order = stopLossOrders.first {
            AbacusStateManager.shared.triggerOrders(input: order.id, type: .stoplossorderid)
            AbacusStateManager.shared.triggerOrders(input: order.size.description, type: .stoplossordersize)
            AbacusStateManager.shared.triggerOrders(input: order.type.rawValue, type: .stoplossordertype)
            AbacusStateManager.shared.triggerOrders(input: order.price.description, type: .stoplosslimitprice)
            AbacusStateManager.shared.triggerOrders(input: order.triggerPrice?.stringValue, type: .stoplossprice)
        }

        AbacusStateManager.shared.triggerOrders(input: position?.size?.current?.stringValue, type: .size)
        AbacusStateManager.shared.triggerOrders(input: marketId, type: .marketid)

    }

    override init() {
        let viewModel = dydxTakeProfitStopLossViewModel()

        viewModel.takeProfitStopLossInputAreaViewModel = dydxTakeProfitStopLossInputAreaModel()
        viewModel.takeProfitStopLossInputAreaViewModel?.multipleOrdersExistViewModel = .init()
        viewModel.takeProfitStopLossInputAreaViewModel?.takeProfitPriceInputViewModel = .init(triggerType: .takeProfit)
        viewModel.takeProfitStopLossInputAreaViewModel?.gainInputViewModel = .init(triggerType: .takeProfit)
        viewModel.takeProfitStopLossInputAreaViewModel?.stopLossPriceInputViewModel = .init(triggerType: .stopLoss)
        viewModel.takeProfitStopLossInputAreaViewModel?.lossInputViewModel = .init(triggerType: .stopLoss)

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

        // set up button interactions
        viewModel.takeProfitStopLossInputAreaViewModel?.multipleOrdersExistViewModel?.viewAllAction = {
            Router.shared?.navigate(to: .init(path: "/portfolio/orders"), animated: true, completion: nil)
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
                    self?.viewModel?.submissionReadiness = .readyToSubmit
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
