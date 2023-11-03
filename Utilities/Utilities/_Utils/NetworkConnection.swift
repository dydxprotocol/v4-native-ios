//
//  NetworkConnection.swift
//  Utilities
//
//  Created by John Huang on 5/16/19.
//  Copyright © 2019 dYdX. All rights reserved.
//

import Reachability

@objc public final class NetworkConnection: NSObject, SingletonProtocol {
    public static var shared: NetworkConnection = {
        let connection = NetworkConnection()
        connection.reachability = try? Reachability()
        return connection
    }()

    private var foregroundToken: NotificationToken?
    @objc public dynamic var connected: NSNumber?
    @objc public dynamic var wifi: NSNumber?

    public var reachability: Reachability? {
        didSet {
            if reachability !== oldValue {
                oldValue?.stopNotifier()
                reachabilityObserving = nil
                if let reachability = reachability {
                    reachabilityObserving = NotificationCenter.default.observe(reachability, notification: .reachabilityChanged, do: { [weak self] notification in
                        self?.reachabilityChanged(notification: notification)
                    })
                    do {
                        try reachability.startNotifier()
                    } catch {
                        Console.shared.log("could not start reachability notifier")
                    }
                } else {
                    connected = nil
                    wifi = nil
                }
            }
        }
    }

    private var reachabilityObserving: NotificationToken?

    @objc func reachabilityChanged(notification: Notification) {
        let reachability = notification.object as? Reachability

        switch reachability?.connection {
        case .wifi:
            connected = true
            wifi = true
        case .cellular:
            connected = true
            wifi = false
        case .unavailable:
            connected = false
            wifi = nil
        default:
            break
        }
    }

    public override init() {
        super.init()
        foregroundToken = NotificationCenter.default.observe(notification: UIApplication.willEnterForegroundNotification, do: { [weak self] _ in
            self?.reachability = try? Reachability()
        })
    }

    deinit {
        reachability = nil
    }
}
