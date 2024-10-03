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
    private func parseAnyToString(_ value: Any?) -> String? {
        guard let value = value else {
            return nil
        }
        switch value {
        case let stringValue as String:
            return stringValue
        case let intValue as Int:
            return String(intValue)
        case let doubleValue as Double:
            return String(doubleValue)
        case let boolValue as Bool:
            return String(boolValue)
        case let arrayValue as [Any]:
            if let jsonString = parseAsJsonString(arrayValue) {
                return jsonString
            }
        case let dictValue as [String: Any]:
            if let jsonString = parseAsJsonString(dictValue) {
                return jsonString
            }
        default:
            return "\(value)"
        }
        return "\(value)"
    }

    private func parseAsJsonString(_ value: Any) -> String? {
        if let jsonData = try? JSONSerialization.data(withJSONObject: value, options: .prettyPrinted),
            let jsonString = String(data: jsonData, encoding: .utf8) {
            return jsonString
        }
        return nil
    }

    override public init() {
        super.init()
        FirebaseConfiguration.shared.setLoggerLevel(.min)
        Analytics.setUserProperty(String(format: "%.4f", UIDevice.current.systemVersionAsFloat), forName: "os_version")
    }

    override public func setUserId(_ userId: String?) {
        Console.shared.log("analytics log | Firebase: User ID set to: `\(userId ?? "nil")`")
        Analytics.setUserID(userId)
    }

    override public func setValue(_ value: Any?, forUserProperty userProperty: String) {
        Console.shared.log("analytics log | Firebase: User Property `\(userProperty)` set to: \(value ?? "nil")")
        // firebase max supported length is 36, this is best effort
        if let valueString = parseAnyToString(value) {
            Analytics.setUserProperty(String(valueString.prefix(36)), forName: userProperty)
        } else {
            Analytics.setUserProperty(nil, forName: userProperty)
        }
    }

    override public func log(event: String, data: [String: Any]?, revenue: NSNumber?) {
        if !excluded {
            DispatchQueue.global().async {
                Analytics.logEvent(event, parameters: data)
            }
        }
    }
}
