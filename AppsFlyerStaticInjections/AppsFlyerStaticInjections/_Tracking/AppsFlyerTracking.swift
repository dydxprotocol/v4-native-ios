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
    
    public override func setUserId(_ userId: String?) {
        AppsFlyerLib.shared().customerUserID = userId
    }
    
    public override func setValue(_ value: Any?, forUserProperty userProperty: String) {
        if AppsFlyerLib.shared().customData == nil {
            AppsFlyerLib.shared().customData = [String: Any]()
        }
        AppsFlyerLib.shared().customData?[userProperty] = value
    }
}
