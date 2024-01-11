//
//  AnalyticsProtocol.swift
//  TrackingKit
//
//  Created by Qiang Huang on 10/8/18.
//  Copyright © 2019 dYdX. All rights reserved.
//

import Foundation

public protocol TrackingProtocol: NSObjectProtocol {
    var userInfo: [String: String?]? { get set }
    var excluded: Bool { get set }
    func view(_ path: String?, action: String?, data: [String: Any]?, from: String?, time: Date?, revenue: NSNumber?)
    func leave(_ path: String?)
    func log(event: String, data: [String: Any]?, revenue: NSNumber?)
}

public extension TrackingProtocol {
    func view(_ path: String?, data: [String: Any]?, from: String?, time: Date?, revenue: NSNumber?) {
        view(path, action: nil, data: data, from: from, time: time, revenue: revenue)
    }
    func view(_ path: String?, data: [String: Any]?, from: String?, time: Date?) {
        view(path, action: nil, data: data, from: from, time: time, revenue: nil)
    }
    func view(_ path: String?, data: [String: Any]?, from: String?) {
        view(path, action: nil, data: data, from: from, time: nil, revenue: nil)
    }
    func view(_ path: String?, data: [String: Any]?) {
        view(path, action: nil, data: data, from: nil, time: nil, revenue: nil)
    }
    func log(event: String, data: [String: Any]?) {
        log(event: event, data: data, revenue: nil)
    }

    func setUserInfo(key: String, value: String?) {
        var userInfo = userInfo ?? [String: String?]()
        userInfo[key] = value
        self.userInfo = userInfo
    }
}

public class Tracking {
    public static var shared: TrackingProtocol?
}

public class TrackingData {
    public var path: String
    public var data: [String: Any]?
    public var startTime: Date

    public init(path: String, data: [String: Any]?) {
        self.path = path
        self.data = data
        startTime = Date()
    }
}

public protocol TrackingViewProtocol {
    var trackingData: TrackingData? { get }
    func logView(path: String?, data: [String: Any]?, from: String?, time: Date?)
}
