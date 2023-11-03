//
//  dydxOrderDetailsViewBuilder.swift
//  dydxPresenters
//
//  Created by Rui Huang on 1/10/23.
//

import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI
import Abacus
import dydxStateManager
import Combine
import dydxFormatter
import SwiftUI

public class dydxOrderDetailsViewBuilder: NSObject, ObjectBuilderProtocol {
    public func build<T>() -> T? {
        let presenter = dydxOrderDetailsViewPresenter()
        let view = presenter.viewModel?.createView() ?? PlatformViewModel().createView()
        let configuration = HostingViewControllerConfiguration(fixedHeight: UIScreen.main.bounds.height)
        return dydxOrderDetailsViewController(presenter: presenter, view: view, configuration: configuration) as? T
    }
}

private class dydxOrderDetailsViewController: HostingViewController<PlatformView, dydxOrderDetailsViewModel> {
    override public func arrive(to request: RoutingRequest?, animated: Bool) -> Bool {
        if request?.path == "/order" || request?.path == "/orders"{
            if let presenter = presenter as? dydxOrderDetailsViewPresenter,
               let orderOrFillId = request?.params?["id"] as? String {
                presenter.orderOrFillId = orderOrFillId
                return true
            }
        }
        return false
    }
}

private protocol dydxOrderDetailsViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxOrderDetailsViewModel? { get }
}

private class dydxOrderDetailsViewPresenter: HostedViewPresenter<dydxOrderDetailsViewModel>, dydxOrderDetailsViewPresenterProtocol {

    fileprivate var orderOrFillId: String?

    override init() {
        super.init()

        viewModel = dydxOrderDetailsViewModel()
    }

    override func start() {
        super.start()

        guard let orderOrFillId = orderOrFillId else { return }
        Publishers
            .CombineLatest3(AbacusStateManager.shared.state.selectedSubaccountFills,
                           AbacusStateManager.shared.state.selectedSubaccountOrders,
                           AbacusStateManager.shared.state.configsAndAssetMap)
            .sink { [weak self] fills, orders, configsAndAssetMap in
                if let fill = fills.first(where: { $0.id == orderOrFillId }) {
                    self?.updateFill(fill: fill, configsAndAssetMap: configsAndAssetMap)
                } else if let order = orders.first(where: { $0.id == orderOrFillId }) {
                    self?.updateOrder(order: order, configsAndAssetMap: configsAndAssetMap)
                }
            }
            .store(in: &subscriptions)

    }

    private func updateFill(fill: SubaccountFill, configsAndAssetMap: [String: MarketConfigsAndAsset]) {
        guard let sharedFillViewModel = dydxPortfolioFillsViewPresenter.createViewModelItem(fill: fill, configsAndAssetMap: configsAndAssetMap) else {
            return
        }

        viewModel?.logoUrl = sharedFillViewModel.logoUrl

        if fill.side == Abacus.OrderSide.buy {
            viewModel?.side = SideTextViewModel(side: .buy)
        } else if fill.side == Abacus.OrderSide.sell {
            viewModel?.side = SideTextViewModel(side: .sell)
        }

        let items: [dydxOrderDetailsViewModel.Item] = [
            .init(title: DataLocalizer.localize(path: "APP.GENERAL.MARKET"),
                  value: .any(sharedFillViewModel.token)),

            .init(title: DataLocalizer.localize(path: "APP.GENERAL.TYPE"),
                  value: .string(DataLocalizer.localize(path: fill.resources.typeStringKey ?? ""))),

            .init(title: DataLocalizer.localize(path: "APP.GENERAL.STATUS"),
                  value: .string(DataLocalizer.localize(path: "APP.TRADE.ORDER_FILLED"))),

            .init(title: DataLocalizer.localize(path: "APP.TRADE.LIQUIDITY"),
                  value: .string(sharedFillViewModel.feeLiquidity)),

            .init(title: DataLocalizer.localize(path: "APP.GENERAL.SIZE"),
                  value: .number(sharedFillViewModel.size)),

            .init(title: DataLocalizer.localize(path: "APP.TRADE.AMOUNT_FILLED"),
                  value: .number(sharedFillViewModel.size)),

            .init(title: DataLocalizer.localize(path: "APP.GENERAL.PRICE"),
                  value: .number(sharedFillViewModel.price)),

            .init(title: DataLocalizer.localize(path: "APP.TRADE.FEE"),
                  value: .number(sharedFillViewModel.fee)),

            .init(title: DataLocalizer.localize(path: "APP.GENERAL.CREATED_AT"),
                  value: .string(dydxFormatter.shared.dateAndTime(date: Date(milliseconds: fill.createdAtMilliseconds))))
        ]

        viewModel?.items = items
        viewModel?.cancelAction = nil
    }

    private func updateOrder(order: SubaccountOrder, configsAndAssetMap: [String: MarketConfigsAndAsset]) {
        guard let sharedOrderViewModel = dydxPortfolioOrdersViewPresenter.createViewModelItem(order: order, configsAndAssetMap: configsAndAssetMap) else {
            return
        }

        viewModel?.logoUrl = sharedOrderViewModel.logoUrl

        if order.side == Abacus.OrderSide.buy {
            viewModel?.side = SideTextViewModel(side: .buy)
        } else if order.side == Abacus.OrderSide.sell {
            viewModel?.side = SideTextViewModel(side: .sell)
        }

        var timePlaced: dydxOrderDetailsViewModel.Item? {
            if let createdAtMilliseconds = order.createdAtMilliseconds?.doubleValue {
                let text = dydxFormatter.shared.dateAndTime(date: Date(milliseconds: createdAtMilliseconds))
                return dydxOrderDetailsViewModel.Item(title: DataLocalizer.localize(path: "APP.TRADE.PLACED"),
                                                      value: .string(text))
            }
            return nil
        }

        var goodTil: dydxOrderDetailsViewModel.Item? {
            if order.timeInForce == .gtt,
               let expiresAtMilliseconds = order.expiresAtMilliseconds?.doubleValue {
                let text = dydxFormatter.shared.interval(time: Date(milliseconds: expiresAtMilliseconds))
                return dydxOrderDetailsViewModel.Item(title: DataLocalizer.localize(path: "APP.TRADE.GOOD_TIL"),
                                                      value: .string(text))
            }
            return nil
        }

        var items: [dydxOrderDetailsViewModel.Item?] = [
            .init(title: DataLocalizer.localize(path: "APP.GENERAL.MARKET"),
                  value: .any(sharedOrderViewModel.token)),

            .init(title: DataLocalizer.localize(path: "APP.GENERAL.TYPE"),
                  value: .string(DataLocalizer.localize(path: order.resources.typeStringKey ?? ""))),

            .init(title: DataLocalizer.localize(path: "APP.GENERAL.STATUS"),
                  value: .string(DataLocalizer.localize(path: order.resources.statusStringKey ?? ""))),

            .init(title: DataLocalizer.localize(path: "APP.GENERAL.SIZE"),
                  value: .number(sharedOrderViewModel.size)),

            .init(title: DataLocalizer.localize(path: "APP.TRADE.AMOUNT_FILLED"),
                  value: .number(sharedOrderViewModel.filledSize)),

            .init(title: DataLocalizer.localize(path: "APP.GENERAL.PRICE"),
                  value: .number(sharedOrderViewModel.price)),

            .init(title: DataLocalizer.localize(path: "APP.TRADE.TRIGGER_PRICE"),
                  value: .number(sharedOrderViewModel.triggerPrice)),

            timePlaced,

            goodTil,

            .init(title: DataLocalizer.localize(path: "APP.TRADE.TIME_IN_FORCE"),
                  value: .string(DataLocalizer.localize(path: order.resources.timeInForceStringKey ?? "")))
        ]

        if order.reduceOnly {
            items.append(.init(title: DataLocalizer.localize(path: "APP.TRADE.REDUCE_ONLY"),
                               value: .checkmark))
        }

        viewModel?.items = items.compactMap { $0 }
        if order.status.canCancel {
            viewModel?.cancelAction = { [weak self] in
                Router.shared?.navigate(to: RoutingRequest(path: "/action/order/cancel", params: ["orderId": self?.orderOrFillId]), animated: true) { _, success in
                    if success {
                        Router.shared?.navigate(to: RoutingRequest(path: "/action/dismiss", params: nil), animated: true, completion: nil)
                    }
                }
            }
        } else {
            viewModel?.cancelAction = nil
        }
    }
}
