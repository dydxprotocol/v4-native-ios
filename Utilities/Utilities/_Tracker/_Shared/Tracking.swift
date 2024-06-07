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
    func view(_ path: String?, action: String?, data: [String: Any]?, from: String?, time: Date?, revenue: NSNumber?, contextViewController: UIViewController?)
    func leave(_ path: String?)
    func log(event: String, data: [String: Any]?, revenue: NSNumber?)
}

public extension TrackingProtocol {
    func view(_ path: String?, data: [String: Any]?, from: String?, time: Date?, revenue: NSNumber?, contextViewController: UIViewController?) {
        view(path, action: nil, data: data, from: from, time: time, revenue: revenue, contextViewController: contextViewController)
    }
    func view(_ path: String?, data: [String: Any]?, from: String?, time: Date?, revenue: NSNumber?) {
        view(path, action: nil, data: data, from: from, time: time, revenue: revenue, contextViewController: nil)
    }
    func view(_ path: String?, data: [String: Any]?, from: String?, time: Date?) {
        view(path, action: nil, data: data, from: from, time: time, revenue: nil, contextViewController: nil)
    }
    func view(_ path: String?, data: [String: Any]?, from: String?, contextViewController: UIViewController?) {
        view(path, action: nil, data: data, from: from, time: nil, revenue: nil, contextViewController: nil)
    }
    func view(_ path: String?, data: [String: Any]?) {
        view(path, action: nil, data: data, from: nil, time: nil, revenue: nil, contextViewController: nil)
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

public protocol TrackableEvent: CustomStringConvertible {
    var name: String { get }
    var customParameters: [String: Any] { get }
}

public extension TrackableEvent {
    var description: String {
        let sorted = customParameters.sorted { $0.key < $1.key }
        return "dydxAnalytics event \(name) with data: \(sorted)"
    }
}

public protocol TrackingViewProtocol: ScreenIdentifiable {
    func logScreenView()
}

public protocol ScreenIdentifiable {
    /// the path identifier specific to mobile
    var mobilePath: String { get }
    /// the web path identifier which corresponds to the mobile screen
    var correspondingWebPath: String? { get }
    var screenClass: String { get }
}
