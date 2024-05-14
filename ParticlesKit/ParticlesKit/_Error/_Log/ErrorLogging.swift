//
//  AnalyticsProtocol.swift
//  TrackingKit
//
//  Created by Qiang Huang on 10/8/18.
//  Copyright © 2019 dYdX. All rights reserved.
//

import Foundation
import Utilities

public protocol ErrorLoggingProtocol: NSObjectProtocol, Logging {
    func log(_ error: Error?)
}

public class ErrorLogging {
    public static var shared: ErrorLoggingProtocol?
}
