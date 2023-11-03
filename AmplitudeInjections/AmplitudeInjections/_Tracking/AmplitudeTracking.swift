//
//  AmplitudeTracking.swift
//  AmplitudeInjections
//
//  Created by John Huang on 4/19/22.
//

import Amplitude_iOS
import PlatformParticles
import Utilities

open class AmplitudeTracking: TransformerTracker {
    override public var userInfo: [String: String?]? {
        didSet {
            let userIdKey = "walletAddress"
            if let userInfo = userInfo {
                if let userId = userInfo[userIdKey] {
                    Console.shared.log("Amplitude: User ID set to walletAddress: \(userId ?? "nil")")
                    Amplitude.instance().setUserId(userId)
                }
            }
            if var thinned = userInfo?.compactMapValues({ value in
                value
            }) {
                thinned.removeValue(forKey: userIdKey)
                Amplitude.instance().setUserProperties(thinned)
            } else {
                Amplitude.instance().setUserProperties(nil)
            }
            Console.shared.log("Amplitude: user properties were set to: \((userInfo ?? [:]).description)")
        }
    }
    
    override open func log(event: String, data: [String: Any]?, revenue: NSNumber?) {
        if !excluded {
            var data = data
            if let revenue = revenue {
                if data == nil {
                    data = [String: Any]()
                }
                data?["$revenue"] = revenue
            }
            Console.shared.log("Amplitude: logging event \(event) with data: \((data ?? [:]).description)")
            Amplitude.instance().logEvent(event, withEventProperties: data)
        }
    }
}
