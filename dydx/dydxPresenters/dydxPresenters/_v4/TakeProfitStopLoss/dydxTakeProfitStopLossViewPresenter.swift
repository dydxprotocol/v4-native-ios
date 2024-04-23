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

        guard let marketId = marketId else { return }
        AbacusStateManager.shared.triggerOrders(input: marketId, type: .marketid)

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

        AbacusStateManager.shared.state.triggerOrdersInput
            .compactMap { $0 }
            .sink { [weak self] triggerOrdersInput in
                self?.update(triggerOrdersInput: triggerOrdersInput)
            }
            .store(in: &subscriptions)
    }

    private func update(market: PerpetualMarket?) {
        viewModel?.oraclePrice = market?.oraclePrice?.doubleValue
    }

    private func update(triggerOrdersInput: TriggerOrdersInput?) {
        viewModel?.takeProfitStopLossInputAreaViewModel?.takeProfitPriceInputViewModel?.value = dydxFormatter.shared.dollar(number: triggerOrdersInput?.takeProfitOrder?.price?.triggerPrice?.doubleValue)
        viewModel?.takeProfitStopLossInputAreaViewModel?.gainInputViewModel?.value = dydxFormatter.shared.dollar(number: triggerOrdersInput?.takeProfitOrder?.price?.usdcDiff?.doubleValue)
        viewModel?.takeProfitStopLossInputAreaViewModel?.stopLossPriceInputViewModel?.value = dydxFormatter.shared.dollar(number: triggerOrdersInput?.stopLossOrder?.price?.triggerPrice?.doubleValue)
        viewModel?.takeProfitStopLossInputAreaViewModel?.lossInputViewModel?.value = dydxFormatter.shared.dollar(number: triggerOrdersInput?.stopLossOrder?.price?.usdcDiff?.doubleValue)
    }

    private func update(subaccountPositions: [SubaccountPosition], subaccountOrders: [SubaccountOrder]) {
        // TODO: move this logic to abacus
        let position = subaccountPositions.first { subaccountPosition in
            subaccountPosition.id == marketId
        }
        let takeProfitOrders = subaccountOrders.filter { (order: SubaccountOrder) in
            order.marketId == marketId && (order.type == .takeprofitmarket || order.type == .takeprofitlimit) && order.side.opposite == position?.side.current
        }
        let stopLossOrders = subaccountOrders.filter { (order: SubaccountOrder) in
            order.marketId == marketId && (order.type == .stopmarket || order.type == .stoplimit) && order.side.opposite == position?.side.current
        }

        viewModel?.entryPrice = position?.entryPrice?.current?.doubleValue

        viewModel?.takeProfitStopLossInputAreaViewModel?.numOpenTakeProfitOrders = takeProfitOrders.count
        viewModel?.takeProfitStopLossInputAreaViewModel?.numOpenStopLossOrders = stopLossOrders.count

        if takeProfitOrders.count == 1, let order = takeProfitOrders.first {
            AbacusStateManager.shared.triggerOrders(input: order.size.description, type: .takeprofitordersize)
            AbacusStateManager.shared.triggerOrders(input: order.type.rawValue, type: .takeprofitordertype)
            AbacusStateManager.shared.triggerOrders(input: order.price.description, type: .takeprofitlimitprice)
            AbacusStateManager.shared.triggerOrders(input: order.triggerPrice?.stringValue, type: .takeprofitprice)
        }
        if stopLossOrders.count == 1, let order = stopLossOrders.first {
            AbacusStateManager.shared.triggerOrders(input: order.size.description, type: .stoplossordersize)
            AbacusStateManager.shared.triggerOrders(input: order.type.rawValue, type: .stoplossordertype)
            AbacusStateManager.shared.triggerOrders(input: order.price.description, type: .stoplosslimitprice)
            AbacusStateManager.shared.triggerOrders(input: order.triggerPrice?.stringValue, type: .stoplossprice)
        }
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
