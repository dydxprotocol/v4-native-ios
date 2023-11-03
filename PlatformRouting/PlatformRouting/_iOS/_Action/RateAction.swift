//
//  RateAction.swift
//  PlatformRouting
//
//  Created by Qiang Huang on 5/11/19.
//  Copyright © 2019 dYdX. All rights reserved.
//

import RoutingKit
import UIKit
import Utilities

open class RateAction: NSObject, NavigableProtocol {
    open func navigate(to request: RoutingRequest?, animated: Bool, completion: RoutingCompletionBlock?) {
        switch request?.path {
        case "/action/rate":
            rate()
            completion?(nil, true)

        default:
            completion?(nil, false)
        }
    }

    open func rate() {
    }
}
