//
//  FilebaseAnalytics.swift
//  TrackingKit
//
//  Created by Qiang Huang on 10/8/18.
//  Copyright © 2019 dYdX. All rights reserved.
//

import FirebaseAnalytics
import FirebaseCore
import PlatformParticles
import Utilities

public class FirebaseTracking: TransformerTracker {
    override public var userInfo: [String: String?]? {
        didSet {
            if let userInfo = userInfo {
                for (key, value) in userInfo {
                    Analytics.setUserProperty(value, forName: key)
                }
            }
        }
    }

    override public init() {
        super.init()
        FirebaseConfiguration.shared.setLoggerLevel(.max)
        Analytics.setUserProperty(String(format: "%.4f", UIDevice.current.systemVersionAsFloat), forName: "os_version")
    }

    override public func log(event: String, data: [String: Any]?, revenue: NSNumber?) {
        if !excluded {
            DispatchQueue.global().async {
                Analytics.logEvent(event, parameters: data)
            }
        }
    }
}
