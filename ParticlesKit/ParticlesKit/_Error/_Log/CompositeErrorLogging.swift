//
//  CompositeTracking.swift
//  TrackingKit
//
//  Created by Qiang Huang on 10/9/18.
//  Copyright © 2019 dYdX. All rights reserved.
//

import Foundation

public class CompositeErrorLogging: NSObject & ErrorLoggingProtocol {
    private var loggings: [ErrorLoggingProtocol] = [ErrorLoggingProtocol]()

    public func add(_ logging: ErrorLoggingProtocol?) {
        if let aLogging = logging {
            loggings.append(aLogging)
        }
    }

    public func log(_ error: Error?) {
        for logging: ErrorLoggingProtocol in loggings {
            logging.log(error)
        }
    }
}
