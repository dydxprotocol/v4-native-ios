//
//  MappedAppleWatchRouter.swift
//  RoutingPlatformAppleWatchLib
//
//  Created by Qiang Huang on 12/7/18.
//  Copyright © 2018 dYdX. All rights reserved.
//

import Foundation
import RoutingKit

open class MappedAppleWatchRouter: MappedRouter {
    open override func navigate(to map: RoutingMap, request: RoutingRequest, presentation: RoutingPresentation?, animated: Bool, completion: RoutingCompletionBlock?) {
        route(storyboard: map, request: request, presentation: presentation, animated: animated) { object, completed in
            completion?(object, completed)
        }
    }

    private func route(storyboard map: RoutingMap, request: RoutingRequest, presentation: RoutingPresentation?, animated: Bool, completion: RoutingCompletionBlock?) {
        route(name: map.destination, request: request, presentation: presentation ?? map.presentation, animated: animated, completion: completion)
    }

    private func route(name: String?, request: RoutingRequest, presentation: RoutingPresentation?, animated: Bool, completion: RoutingCompletionBlock?) {
        if let topmost = WKExtension.shared().visibleInterfaceController, let name = name {
            let presentation = presentation ?? .show
            switch presentation {
            case .show:
                fallthrough
            case .detail:
                topmost.pushController(withName: name, context: request)

            case .prompt:
                topmost.presentController(withName: name, context: request)

            default:
                break
            }
            completion?(nil, true)
        } else {
            completion?(nil, false)
        }
    }
}
