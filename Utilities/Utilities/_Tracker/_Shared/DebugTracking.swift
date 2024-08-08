//
//  DebugTracking.swift
//  ParticlesKit
//
//  Created by John Huang on 12/20/18.
//  Copyright © 2019 dYdX. All rights reserved.
//

import Foundation

public class DebugTracking: NSObject & TrackingProtocol {

    public var excluded: Bool = false
    
    public func setUserId(_ userId: String?) {}
    
    public func setUserProperty(_ value: Any?, forName: String) {}
    
    public func leave(_ path: String?) {
        if let path = path {
            if excluded {
                Console.shared.log("Debug Tracking: Leave Excluded Path:\(path)")
            } else {
                Console.shared.log("Debug Tracking: Leave Path:\(path)")
            }
        }
    }

    open func log(event: String, data: [String: Any]?, revenue: NSNumber?) {
        if let revenue = revenue {
            Console.shared.log("Debug Tracking: event:\(event), revenue:\(revenue), ", data ?? "")
        } else {
            Console.shared.log("Debug Tracking: event:\(event), ", data ?? "")
        }
    }
}
