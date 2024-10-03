//
//  NotificationBridge.swift
//  Utilities
//
//  Created by Qiang Huang on 10/1/20.
//  Copyright © 2020 dYdX. All rights reserved.
//

import Foundation

@objc public protocol NotificationBridgeProtocol: NSObjectProtocol {
    func launched()
    func registered(deviceToken: Data)
    func failed(error: Error)
    func received(userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void)
    func receivedDeeplink(userInfo: [AnyHashable: Any]) -> URL?
}

public class NotificationBridge: NSObject {
    public static var shared: NotificationBridgeProtocol?
}

public class CompositeNotificationBridge: NSObject, NotificationBridgeProtocol {

    private var bridges: [NotificationBridgeProtocol]?

    public func add(bridge: NotificationBridgeProtocol) {
        if bridges == nil {
            bridges = [NotificationBridgeProtocol]()
        }
        bridges?.append(bridge)
    }

    public func launched() {
        if let bridges = bridges {
            for bridge in bridges {
                bridge.launched()
            }
        }
    }

    public func registered(deviceToken: Data) {
        if let bridges = bridges {
            for bridge in bridges {
                bridge.registered(deviceToken: deviceToken)
            }
        }
    }

    public func failed(error: Error) {
        if let bridges = bridges {
            for bridge in bridges {
                bridge.failed(error: error)
            }
        }
    }

    public func received(userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        received(userInfo: userInfo, index: 0, results: Set<UIBackgroundFetchResult>(), fetchCompletionHandler: completionHandler)
    }

    public func receivedDeeplink(userInfo: [AnyHashable: Any]) -> URL? {
        bridges?.first?.receivedDeeplink(userInfo: userInfo)
    }

    public func received(userInfo: [AnyHashable: Any], index: Int, results: Set<UIBackgroundFetchResult>, fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if let bridge = bridges?.object(at: index) {
            bridge.received(userInfo: userInfo) { [weak self] result in
                var results = results
                results.insert(result)
                self?.received(userInfo: userInfo, index: index + 1, results: results, fetchCompletionHandler: completionHandler)
            }
        } else {
            completionHandler(result(results: results))
        }
    }

    private func result(results: Set<UIBackgroundFetchResult>) -> UIBackgroundFetchResult {
        if results.contains(.newData) {
            return .newData
        } else if results.contains(.noData) {
            return .noData
        } else {
            return .failed
        }
    }
}
