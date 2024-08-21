//
//  ReachabilityManager.swift
//  UIToolkits
//
//  Created by Qiang Huang on 5/15/19.
//  Copyright © 2019 dYdX. All rights reserved.
//

import SwiftMessages
import Utilities

public final class ReachabilityMessage: NSObject, SingletonProtocol {
    public var connectivityXib: String?
    @objc var connection: NetworkConnection? {
        didSet {
            changeObservation(from: oldValue, to: connection, keyPath: #keyPath(NetworkConnection.connected)) { [weak self] _, _, _, _ in
                self?.updateConnectivityMessage()
            }
        }
    }

    public static var shared: ReachabilityMessage = {
        let reachability = ReachabilityMessage()
        reachability.connection = NetworkConnection.shared
        return reachability
    }()

    private func updateConnectivityMessage() {
        if let connected = connection?.connected?.boolValue, !connected {
            let error = NSError(domain: "reachability", code: 400, userInfo: nil)
            ErrorInfo.shared?.info(title: "Network", message: "Connection not available", type: .info, error: error)
        }
    }
}
