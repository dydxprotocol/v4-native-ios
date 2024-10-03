//
//  GraphingAnchorProtocol.swift
//  Utilities
//
//  Created by Qiang Huang on 11/1/21.
//  Copyright © 2021 dYdX Trading Inc. All rights reserved.
//

import Foundation

@objc public protocol GraphingAnchorProtocol: NSObjectProtocol {
    var date: Date { get }
}

@objc public class GraphingAnchor: NSObject {
    public static var shared: GraphingAnchorProtocol?
}

@objc public class StandardGraphingAnchor: NSObject, GraphingAnchorProtocol {
    private var _graphingAnchor: Date?

    public var date: Date {
        if _graphingAnchor == nil {
            let now = Date()
            var calendar = Calendar.current
            calendar.timeZone = TimeZone(identifier: "UTC")!
            let components = calendar.dateComponents([.year, .month, .day], from: now)
            _graphingAnchor = calendar.date(from: components)
        }
        return _graphingAnchor!
    }
}
