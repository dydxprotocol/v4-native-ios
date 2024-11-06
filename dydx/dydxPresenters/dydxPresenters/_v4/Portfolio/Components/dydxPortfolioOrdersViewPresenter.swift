//
//  dydxPortfolioOrdersViewPresenter.swift
//  dydxPresenters
//
//  Created by Rui Huang on 1/9/23.
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

protocol dydxPortfolioOrdersViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxPortfolioOrdersViewModel? { get }
}

class dydxPortfolioOrdersViewPresenter: HostedViewPresenter<dydxPortfolioOrdersViewModel>, dydxPortfolioOrdersViewPresenterProtocol {
    @Published var filterByMarketId: String?

    private var cache = [String: dydxPortfolioOrderItemViewModel]()

    init(viewModel: dydxPortfolioOrdersViewModel?) {
        super.init()

        self.viewModel = viewModel
    }

    override func start() {
        super.start()

        AbacusStateManager.shared.state.onboarded
            .sink { [weak self] onboarded in
                if onboarded {
                    self?.viewModel?.placeholderText = DataLocalizer.localize(path: "APP.GENERAL.PLACEHOLDER_NO_ORDERS")
                } else {
                    self?.viewModel?.placeholderText = DataLocalizer.localize(path: "APP.GENERAL.PLACEHOLDER_NO_ORDERS_LOG_IN")
                }
            }
            .store(in: &subscriptions)

        Publishers
            .CombineLatest3(
                $filterByMarketId.removeDuplicates(),
                AbacusStateManager.shared.state.selectedSubaccountOrders,
                AbacusStateManager.shared.state.configsAndAssetMap)
            .sink { [weak self] filterByMarketId, positions, configsAndAssetMap in
                self?.updateOrders(filterByMarketId: filterByMarketId, orders: positions, configsAndAssetMap: configsAndAssetMap)
            }
            .store(in: &subscriptions)
    }

    private func updateOrders(filterByMarketId: String?, orders: [SubaccountOrder], configsAndAssetMap: [String: MarketConfigsAndAsset]) {
        let items: [dydxPortfolioOrderItemViewModel] = orders.compactMap { order -> dydxPortfolioOrderItemViewModel? in
            if let filterByMarketId = filterByMarketId, filterByMarketId != order.marketId {
                return nil
            }

            let item = Self.createViewModelItem(order: order, configsAndAssetMap: configsAndAssetMap, cache: cache)
            cache[order.id] = item
            return item
        }

        self.viewModel?.items = items
    }

    static func createViewModelItem(order: SubaccountOrder, configsAndAssetMap: [String: MarketConfigsAndAsset], cache: [String: dydxPortfolioOrderItemViewModel]? = nil) -> dydxPortfolioOrderItemViewModel? {
        guard let configsAndAsset = configsAndAssetMap[order.marketId], let configs = configsAndAsset.configs, let asset = configsAndAsset.asset else {
            return nil
        }

        let item = cache?[order.id] ?? dydxPortfolioOrderItemViewModel()

        item.id = order.id
        item.type = DataLocalizer.localize(path: order.resources.typeStringKey ?? "-")
        if order.side == Abacus.OrderSide.buy {
            item.sideText.side = .buy
        } else {
            item.sideText.side = .sell
        }
        item.status = DataLocalizer.localize(path: order.resources.statusStringKey ?? "-")
        item.canCancel = order.status.canCancel
        item.orderStatus = OrderStatusModel(order: order)
        if let orderDate = order.createdAtMilliseconds?.doubleValue {
            item.date = Date(milliseconds: orderDate)
        }
        item.size = dydxFormatter.shared.localFormatted(number: order.size, digits: configs.displayStepSizeDecimals?.intValue ?? 1)
        let filledSize: Double
        if let remainingSize = order.remainingSize?.doubleValue {
            filledSize = order.size - remainingSize
        } else {
            filledSize = 0
        }
        item.filledSize = dydxFormatter.shared.localFormatted(number: filledSize, digits: configs.displayStepSizeDecimals?.intValue ?? 1)
        if let tickSize = configs.displayTickSizeDecimals?.intValue {
            switch order.type {
            case .market:
                item.price = DataLocalizer.localize(path: "APP.GENERAL.MARKET")
            case .stopmarket, .takeprofitmarket:
                item.price = dydxFormatter.shared.dollar(number: order.triggerPrice?.doubleValue, digits: tickSize)
            default:
                item.price = dydxFormatter.shared.dollar(number: order.price, digits: tickSize)
            }
            if let triggerPrice = order.triggerPrice?.doubleValue {
                item.triggerPrice = dydxFormatter.shared.dollar(number: triggerPrice, digits: tickSize)
            }
        }
        if let symbol = configsAndAsset.asset?.displayableAssetId {
            item.token = TokenTextViewModel(symbol: symbol)
        }
        if let url = asset.resources?.imageUrl {
            item.logoUrl = URL(string: url)
        }
        item.handler?.onTapAction = {
            Router.shared?.navigate(to: RoutingRequest(path: "/order", params: ["id": order.id]), animated: true, completion: nil)
        }
        item.handler?.onCloseAction = {
            Router.shared?.navigate(to: RoutingRequest(path: "/action/order/cancel",
                                                       params: [
                                                        "orderId": order.id,
                                                        "orderSide": item.sideText.side.text,
                                                        "orderSize": item.size ?? "",
                                                        "orderMarket": item.token?.symbol ?? ""
                                                       ]),
                                    animated: true, completion: nil)
        }

        return item
    }
}
