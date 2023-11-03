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
            if let orderId = request?.params?["orderId"] as? String {
                cancelOrder(orderId: orderId, completion: completion)
            } else {
                assertionFailure("orderId not found at dydxCancelOrderAction")
                completion?(nil, false)
            }
        default:
            completion?(nil, false)
        }
    } 

    private func cancelOrder(orderId: String, completion: RoutingCompletionBlock?) {
        AbacusStateManager.shared.cancelOrder(orderId: orderId) { status in
            switch status {
            case .success:
                ErrorInfo.shared?.info(title: nil, message: DataLocalizer.localize(path: "APP.GENERAL.CANCELED"), type: .success, error: nil)
                completion?(nil, true)
            case .failed(let error):
                ErrorInfo.shared?.info(title: nil, message: nil, type: .error, error: error)
                HapticFeedback.shared?.notify(type: .error)
                completion?(nil, false)
            }
        }
    }
}
