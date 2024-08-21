//
//  RouterProtocol.swift
//  RoutingKit
//
//  Created by Qiang Huang on 10/11/18.
//  Copyright © 2018 dYdX. All rights reserved.
//

import Foundation

public typealias RoutingCompletionBlock = (Any?, Bool) -> Void

@objc public protocol RoutingOriginatorProtocol: NSObjectProtocol {
    func routingRequest() -> RoutingRequest?

    @objc optional func identifierParams() -> [String: Any]?
}

public protocol RouterProtocol: NSObjectProtocol {
    var disabled: Bool { get set }
    func navigate(to request: RoutingRequest, animated: Bool, completion: RoutingCompletionBlock?)
    func navigate(to request: RoutingRequest, presentation: RoutingPresentation?, animated: Bool, completion: RoutingCompletionBlock?)
    func navigate(to originator: RoutingOriginatorProtocol, animated: Bool, completion: RoutingCompletionBlock?)
    func navigate(to originator: RoutingOriginatorProtocol, presentation: RoutingPresentation?, animated: Bool, completion: RoutingCompletionBlock?)
    func navigate(to url: URL?, completion: RoutingCompletionBlock?)
}

public extension RouterProtocol {
    func navigate(to request: RoutingRequest, animated: Bool, completion: RoutingCompletionBlock?) {
        navigate(to: request, presentation: nil, animated: animated, completion: completion)
    }

    func navigate(to originator: RoutingOriginatorProtocol, animated: Bool, completion: RoutingCompletionBlock?) {
        navigate(to: originator, presentation: nil, animated: animated, completion: completion)
    }

    func navigate(to originator: RoutingOriginatorProtocol, presentation: RoutingPresentation?, animated: Bool, completion: RoutingCompletionBlock?) {
        if let routingRequest = originator.routingRequest() {
            navigate(to: routingRequest, presentation: presentation, animated: animated, completion: completion)
        }
    }
}

public class Router {
    public static var shared: RouterProtocol?
}

@objc public protocol NavigableProtocol: NSObjectProtocol {
    @objc func navigate(to request: RoutingRequest?, animated: Bool, completion: RoutingCompletionBlock?)

    @objc optional var history: RoutingRequest? { get }
}
