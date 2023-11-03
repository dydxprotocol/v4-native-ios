//
//  AppsFlyerInjections.swift
//  AppsFlyerInjections
//
//  Created by Qiang Huang on 7/24/19.
//  Copyright © 2019 dYdX. All rights reserved.
//

import AppsFlyerLib
import PlatformParticles
import Utilities

public class AppsFlyerTracking: TransformerTracker {
    override public var userInfo: [String: String?]? {
        didSet {
            let userIdKey = "User ID"
            if let userInfo = userInfo {
                if let userId = userInfo[userIdKey] {
                    AppsFlyerLib.shared().customerUserID = userId
                }
            }
            if var thinned = userInfo?.compactMapValues({ value in
                value
            }) {
                thinned.removeValue(forKey: userIdKey)
                AppsFlyerLib.shared().customData = thinned
            } else {
                AppsFlyerLib.shared().customData = nil
            }
        }
    }

    override open func view(_ path: String?, action: String?, data: [String: Any]?, from: String?, time: Date?, revenue: NSNumber?) {
        // Only track the ones required by growth
    }

    override public func log(event: String, data: [String: Any]?, revenue: NSNumber?) {
        if !excluded {
            var data = data
            if let revenue = revenue {
                if data == nil {
                    data = [String: Any]()
                }
                data?["af_revenue"] = revenue
            }
            AppsFlyerLib.shared().logEvent(event, withValues: data)
        }
    }
}
