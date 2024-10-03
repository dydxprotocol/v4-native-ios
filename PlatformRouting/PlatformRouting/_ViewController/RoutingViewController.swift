//
//  NavigableViewController.swift
//  PlatformRouting
//
//  Created by Qiang Huang on 11/20/18.
//  Copyright © 2018 dYdX. All rights reserved.
//

import RoutingKit
import UIKit
import UIToolkits

open class NavigableViewController: KeyboardAdjustingViewController, NavigableProtocol {
    open var routingRequest: RoutingRequest?

    open var history: RoutingRequest? {
        return routingRequest
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        #if _iOS
            if navigationItem.backBarButtonItem == nil {
                navigationItem.backBarButtonItem = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
            }
        #endif
    }

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        print("\(String(describing: type(of: self))) viewWillAppear")
//        printTransitionStates()
        if let tabbarController = tabBarController ?? navigationController?.tabBarController {
            _ = RoutingHistory.shared.makeLast(destination: tabbarController)
        }
        RoutingHistory.shared.record(destination: self)
    }

    open func arrive(to request: RoutingRequest?, animated: Bool) -> Bool {
        if let routingRequest = routingRequest {
            return routingRequest.path == request?.path && (routingRequest.params as NSDictionary?) == (request?.params as NSDictionary?)
        } else {
            return true
        }
    }

    open func navigate(to request: RoutingRequest?, animated: Bool, completion: RoutingCompletionBlock?) {
        if arrive(to: request, animated: animated) {
            routingRequest = request
            completion?(self, true)
        } else {
            completion?(self, false)
        }
    }
}
