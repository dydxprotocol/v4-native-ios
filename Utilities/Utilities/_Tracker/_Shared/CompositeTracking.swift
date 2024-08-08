//
//  CompositeTracking.swift
//  TrackingKit
//
//  Created by Qiang Huang on 10/9/18.
//  Copyright © 2019 dYdX. All rights reserved.
//

import Foundation

open class CompositeTracking: NSObject & TrackingProtocol {
    public var userInfo: [String: Any]? {
        get {
            return trackings.first?.userInfo
        }
        set {
            for tracking in trackings {
                tracking.userInfo = newValue
            }
        }
    }

    public var excluded: Bool = false {
        didSet {
            if excluded != oldValue {
                for tracking in trackings {
                    tracking.excluded = excluded
                }
            }
        }
    }

    private var trackings: [TrackingProtocol] = [TrackingProtocol]()

    open func add(_ tracking: TrackingProtocol?) {
        if let aTracking = tracking {
            aTracking.excluded = excluded
            trackings.append(aTracking)
        }
    }

    open func leave(_ path: String?) {
        for tracking: TrackingProtocol in trackings {
            tracking.leave(path)
        }
    }

    open func log(event: String, data: [String: Any]?, revenue: NSNumber?) {
        for tracking: TrackingProtocol in trackings {
            tracking.log(event: event, data: data, revenue: revenue)
        }
    }
}
