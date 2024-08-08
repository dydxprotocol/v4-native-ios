//
//  AnalyticsProtocol.swift
//  TrackingKit
//
//  Created by Qiang Huang on 10/8/18.
//  Copyright © 2019 dYdX. All rights reserved.
//

import Foundation

public protocol TrackingProtocol: NSObjectProtocol {
    var excluded: Bool { get set }
    func setUserId(_ userId: String?)
    func setUserProperty(_ value: Any?, forName: String)
    func leave(_ path: String?)
    func log(event: String, data: [String: Any]?, revenue: NSNumber?)
}

public extension TrackingProtocol {
    func log(event: String, data: [String: Any]?) {
        log(event: event, data: data, revenue: nil)
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
