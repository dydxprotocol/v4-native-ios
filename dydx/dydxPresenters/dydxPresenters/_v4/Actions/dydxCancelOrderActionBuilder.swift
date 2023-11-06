//
//  dydxCancelOrderActionBuilder.swift
//  dydxPresenters
//
//  Created by Rui Huang on 3/12/23.
//

import Foundation
import Utilities
import RoutingKit
import dydxStateManager
import Combine

public class dydxCancelOrderActionBuilder: NSObject, ObjectBuilderProtocol {
    public func build<T>() -> T? {
        let action = dydxCancelOrderAction()
        return action as? T
    }
}

private class dydxCancelOrderAction: NSObject, NavigableProtocol {
    private var subscriptions = Set<AnyCancellable>()

    func navigate(to request: RoutingRequest?, animated: Bool, completion: RoutingCompletionBlock?) {
        switch request?.path {
        case "/action/order/cancel":
            if let orderId = request?.params?["orderId"] as? String,
               let side = request?.params?["orderSide"] as? String,
               let size = request?.params?["orderSize"] as? String,
               let market = request?.params?["orderMarket"] as? String {
                cancelOrder(orderId: orderId, side: side, size: size, market: market, completion: completion)
            } else {
                assertionFailure("one of orderId, orderSide, orderSize, orderMarket, not found in params dydxCancelOrderAction")
                completion?(nil, false)
            }
        default:
            completion?(nil, false)
        }
    }

    private func cancelOrder(orderId: String, side: String, size: String, market: String, completion: RoutingCompletionBlock?) {
        AbacusStateManager.shared.cancelOrder(orderId: orderId) { status in
            switch status {
            case .success:
                ErrorInfo.shared?.info(
                    title: DataLocalizer.localize(path: "APP.TRADE.CANCELING_ORDER"),
                    message: DataLocalizer.localize(path: "APP.TRADE.CANCELING_ORDER_DESC", params: [
                        "SIDE": side,
                        "SIZE": size,
                        "MARKET": market
                    ]),
                    type: .success, error: nil)
                completion?(nil, true)
            case .failed(let error):
                ErrorInfo.shared?.info(title: nil, message: nil, type: .error, error: error)
                HapticFeedback.shared?.notify(type: .error)
                completion?(nil, false)
            }
        }
    }
}
