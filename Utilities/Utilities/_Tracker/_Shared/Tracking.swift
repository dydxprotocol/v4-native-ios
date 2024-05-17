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
    func leave(_ path: String?)
    func log(event: String, data: [String: Any]?, revenue: NSNumber?)
}

public extension TrackingProtocol {
    func log(event: String, data: [String: Any]?) {
        log(event: event, data: data, revenue: nil)
    }
    func log(trackableEvent: TrackableEvent) {
        log(event: trackableEvent.name, data: trackableEvent.customParameters, revenue: nil)
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

public protocol TrackableEvent {
    var name: String { get }
    var customParameters: [String: Any] { get }
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
