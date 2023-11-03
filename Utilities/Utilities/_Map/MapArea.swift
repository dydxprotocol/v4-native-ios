//
//  MapArea.swift
//  Utilities
//
//  Created by Qiang Huang on 7/18/19.
//  Copyright © 2019 dYdX. All rights reserved.
//

import CoreLocation
import Foundation

public class MapArea: NSObject {
    public static func check(latitude: Double?, longitude: Double?, minLatitude: inout Double?, maxLatitude: inout Double?, minLongitude: inout Double?, maxLongitude: inout Double?) {
        if let lat = latitude, let lng = longitude {
            if minLatitude != nil, maxLatitude != nil, minLongitude != nil, maxLongitude != nil {
                minLatitude = min(lat, minLatitude!)
                maxLatitude = max(lat, maxLatitude!)
                minLongitude = min(lng, minLongitude!)
                maxLongitude = max(lng, maxLongitude!)
            } else {
                minLatitude = lat
                maxLatitude = lat
                minLongitude = lng
                maxLongitude = lng
            }
        }
    }

    public var topLeft: MapPoint?
    public var bottomRight: MapPoint?
    public var center: MapPoint? {
        if let lat1 = topLeft?.latitude, let lat2 = bottomRight?.latitude, let lng1 = topLeft?.longitude, let lng2 = bottomRight?.longitude {
            let center = MapPoint()
            center.latitude = (lat1 + lat2) / 2
            center.longitude = (lng1 + lng2) / 2
            return center
        }
        return nil
    }

    public var latitudeDelta: Double? {
        if let latitude1 = bottomRight?.latitude, let latitude2 = topLeft?.latitude {
            return latitude1 - latitude2
        }
        return nil
    }

    public var longitudeDelta: Double? {
        if let longitude1 = bottomRight?.longitude, let longitude2 = topLeft?.longitude {
            return longitude1 - longitude2
        }
        return nil
    }

    public var topRight: MapPoint? {
        if let topLeft = topLeft, let bottomRight = bottomRight {
            let topRight = MapPoint()
            topRight.latitude = topLeft.latitude
            topRight.longitude = bottomRight.longitude
            return topRight
        }
        return nil
    }

    public var bottomLeft: MapPoint? {
        if let topLeft = topLeft, let bottomRight = bottomRight {
            let bottomLeft = MapPoint()
            bottomLeft.latitude = bottomRight.latitude
            bottomLeft.longitude = topLeft.longitude
            return bottomLeft
        }
        return nil
    }

    public var valid: Bool {
        return topLeft?.latitude != nil && topLeft?.longitude != nil && bottomRight?.latitude != nil && bottomRight?.longitude != nil
    }

    public init(points: [MapPoint], extend: Double? = nil) {
        super.init()

        var minLatitude: Double?
        var maxLatitude: Double?
        var minLongitude: Double?
        var maxLongitude: Double?
        for point in points {
            type(of: self).check(latitude: point.latitude, longitude: point.longitude, minLatitude: &minLatitude, maxLatitude: &maxLatitude, minLongitude: &minLongitude, maxLongitude: &maxLongitude)
        }
        if var minLatitude = minLatitude, var maxLatitude = maxLatitude, var minLongitude = minLongitude, var maxLongitude = maxLongitude {
            if let extend = extend {
                minLatitude -= extend
                maxLatitude += extend
                minLongitude -= extend
                maxLongitude += extend
            }
            topLeft = MapPoint(latitude: minLatitude, longitude: minLongitude)
            bottomRight = MapPoint(latitude: maxLatitude, longitude: maxLongitude)
        }
    }

    public init(topLeft: MapPoint? = nil, bottomRight: MapPoint? = nil) {
        super.init()
        self.topLeft = topLeft
        self.bottomRight = bottomRight
    }

    public func contains(point: MapPoint?) -> Bool {
        if let latitude = point?.latitude, let longitude = point?.longitude, let topLeftLatitude = topLeft?.latitude, let topLeftLongitude = topLeft?.longitude, let bottomRightLatitude = bottomRight?.latitude, let bottomRightLongitude = bottomRight?.longitude {
            let minLatitude = min(topLeftLatitude, bottomRightLatitude)
            let maxLatitude = max(topLeftLatitude, bottomRightLatitude)
            let minLongitude = min(topLeftLongitude, bottomRightLongitude)
            let maxLongitude = max(topLeftLongitude, bottomRightLongitude)
            return latitude >= minLatitude && latitude <= maxLatitude && longitude >= minLongitude && longitude <= maxLongitude
        }
        return false
    }

    public func shift(to point: MapPoint?) -> MapArea? {
        if let point = point, let latitude = point.latitude, let longitude = point.longitude {
            if let latitudeDelta = latitudeDelta, let longitudeDelta = longitudeDelta {
                return MapArea(topLeft: MapPoint(latitude: latitude - latitudeDelta / 2.0, longitude: longitude - longitudeDelta / 2.0), bottomRight: MapPoint(latitude: latitude + latitudeDelta / 2.0, longitude: longitude + longitudeDelta / 2.0))
            } else {
                return nil
            }
        } else {
            return self
        }
    }

    public func radius() -> Double? {
        if let topLeft = topLeft, let bottomRight = bottomRight, let topLeftLatitude = topLeft.latitude, let topLeftLongitude = topLeft.longitude, let bottomRightLatitude = bottomRight.latitude, let bottomRightLongitude = bottomRight.longitude {
            let location1 = CLLocation(latitude: topLeftLatitude, longitude: topLeftLongitude)
            let location2 = CLLocation(latitude: bottomRightLatitude, longitude: bottomRightLongitude)
            return location1.distance(from: location2) / 2.0
        }
        return nil
    }

    public func distance() -> Double? {
        if let topLeft = topLeft, let topLeftLatitude = topLeft.latitude, let topLeftLongitude = topLeft.longitude, let bottomRight = bottomRight, let bottomRightLatitude = bottomRight.latitude, let bottomRightLongitude = bottomRight.longitude {
            let point1 = CLLocation(latitude: topLeftLatitude, longitude: topLeftLongitude)
            let point2 = CLLocation(latitude: bottomRightLatitude, longitude: bottomRightLongitude)
            return point1.distance(from: point2)
        }
        return nil
    }

    public func latitudeDistance() -> Double? {
        if let topLeft = topLeft, let topLeftLatitude = topLeft.latitude, let topLeftLongitude = topLeft.longitude, let bottomRight = bottomRight, let bottomRightLatitude = bottomRight.latitude {
            let point1 = CLLocation(latitude: topLeftLatitude, longitude: topLeftLongitude)
            let point2 = CLLocation(latitude: bottomRightLatitude, longitude: topLeftLongitude)
            return point1.distance(from: point2)
        }
        return nil
    }

    public func longitudeDistance() -> Double? {
        if let topLeft = topLeft, let topLeftLatitude = topLeft.latitude, let topLeftLongitude = topLeft.longitude, let bottomRight = bottomRight, let bottomRightLongitude = bottomRight.longitude {
            let point1 = CLLocation(latitude: topLeftLatitude, longitude: topLeftLongitude)
            let point2 = CLLocation(latitude: topLeftLatitude, longitude: bottomRightLongitude)
            return point1.distance(from: point2)
        }
        return nil
    }
}
