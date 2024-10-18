//
//  AmplitudeTracking.swift
//  AmplitudeInjections
//
//  Created by John Huang on 4/19/22.
//

import AmplitudeSwift
import PlatformParticles
import Utilities

open class AmplitudeTracking: TransformerTracker {

    private let amplitude: Amplitude
    
    ///   - serverZone: either "EU" or "US", defaults to US
    public init(_ apiKey: String, serverZone: String) {
        let serverZone: ServerZone = serverZone.uppercased() == "EU" ? .EU : .US
        self.amplitude = Amplitude.init(configuration: .init(apiKey: apiKey, serverZone: serverZone))
        Console.shared.log("analytics log | Amplitude initialized")
        super.init()
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
            Console.shared.log("analytics log | Amplitude: logging event \(event) with data: \((data ?? [:]).description)")
            let event = BaseEvent(eventType: event, eventProperties: data)
            amplitude.track(event: event)
        }
    }

    override public func setUserId(_ userId: String?) {
        Console.shared.log("analytics log | Amplitude: User ID set to: `\(userId ?? "nil")`")
        amplitude.setUserId(userId: userId)
    }

    // https://amplitude.com/docs/sdks/analytics/ios/ios-swift-sdk#identify
    override public func setValue(_ value: Any?, forUserProperty userProperty: String) {
        Console.shared.log("analytics log | Amplitude: User Property `\(userProperty)` set to: \(value ?? "nil")")
        let identify = Identify()
        if value != nil {
            identify.set(property: userProperty, value: value)
        } else {
            identify.unset(property: userProperty)
        }
        amplitude.identify(identify: identify)
    }
}
