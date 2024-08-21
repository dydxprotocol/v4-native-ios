//
//  RoutingAction.swift
//  RoutingKit
//
//  Created by Qiang Huang on 8/10/19.
//  Copyright © 2019 dYdX. All rights reserved.
//

import Foundation

open class RoutingAction: NSObject, NavigableProtocol {
    open var completion: RoutingCompletionBlock?

    deinit {
        complete(successful: false)
    }

    @objc open func navigate(to request: RoutingRequest?, animated: Bool, completion: RoutingCompletionBlock?) {
        completion?(nil, false)
    }

    open func complete(successful: Bool) {
        completion?(nil, successful)
        completion = nil
    }
}
