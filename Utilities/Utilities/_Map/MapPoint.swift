//
//  MapPoint.swift
//  Utilities
//
//  Created by Qiang Huang on 7/18/19.
//  Copyright © 2019 dYdX. All rights reserved.
//

import Foundation

@objc public class MapPoint: NSObject {
    public var latitude: Double?
    public var longitude: Double?

    public init(latitude: Double? = nil, longitude: Double? = nil) {
        self.latitude = latitude
        self.longitude = longitude
    }
}
