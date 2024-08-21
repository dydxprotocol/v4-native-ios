//
//  RoutingInterfaceController.swift
//  RoutingPlatformAppleWatchLib
//
//  Created by Qiang Huang on 12/7/18.
//  Copyright © 2018 dYdX. All rights reserved.
//

import RoutingKit
import WatchKit

open class RoutingInterfaceController: WKInterfaceController, NavigableProtocol {
    open var routingRequest: RoutingRequest?

    open var history: RoutingRequest? {
        return routingRequest
    }

    open override func awake(withContext context: Any?) {
        super.awake(withContext: context)

        if let routingRequest = context as? RoutingRequest {
            navigate(to: routingRequest, animated: true, completion: nil)
        }
    }

    open override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    open override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    open func arrive(to request: RoutingRequest?, animated: Bool) -> Bool {
        return routingRequest?.path == request?.path && (routingRequest?.params as NSDictionary?) == (request?.params as NSDictionary?)
    }

    public func navigate(to request: RoutingRequest?, animated: Bool, completion: RoutingCompletionBlock?) {
        if arrive(to: request, animated: animated) {
            routingRequest = request
            completion?(self, true)
        } else {
            completion?(self, false)
        }
    }
}
