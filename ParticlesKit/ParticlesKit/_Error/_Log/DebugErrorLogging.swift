//
//  DebugTracking.swift
//  ParticlesKit
//
//  Created by John Huang on 12/20/18.
//  Copyright © 2019 dYdX. All rights reserved.
//

import Utilities

public class DebugErrorLogging: NSObject & ErrorLoggingProtocol {
    public func e(tag: String, message: String) {
        Console.shared.log("Error: \(tag) \(message)")
    }

    public func d(tag: String, message: String) {
        Console.shared.log("Debug: \(tag) \(message)")
    }

    public func log(_ error: Error?) {
        if let error = error {
            Console.shared.log("Error:\(error)")
        }
    }
}
