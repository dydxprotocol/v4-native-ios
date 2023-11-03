//
//  PlacesService.swift
//  ParticlesKit
//
//  Created by Qiang Huang on 7/31/19.
//  Copyright © 2019 Qiang Huang. All rights reserved.
//

import Utilities

@objc public protocol PlaceProtocol: ModelObjectProtocol {
    var name: String? { get }
    var address: String? { get }
    var type: String? { get }
    var mapPoint: MapPoint? { get }
}

@objc public protocol PlacesProviderProtocol: NSObjectProtocol {
    var constraint: Bool { get set }
    var searchText: String? { get set }
    var area: MapArea? { get set }
    var places: [PlaceProtocol]? { get set }
}

extension PlacesProviderProtocol {
    public func searchArea() -> MapArea? {
        let coordinate = LocationProvider.shared?.location?.coordinate
        if let area = area {
            let flag = (self as? NSObject)?.parser.asString(FeatureService.shared?.flag(feature: "auto_complete_area"))
            switch flag {
            case "user":
                if let coordinate = coordinate {
                    return area.shift(to: MapPoint(latitude: coordinate.latitude, longitude: coordinate.longitude))
                } else {
                    return area
                }

            case "map":
                fallthrough
            default:
                return area
            }
        } else {
            if let coordinate = coordinate {
                let point1 = MapPoint(latitude: coordinate.latitude - 0.001, longitude: coordinate.longitude - 0.001)
                let point2 = MapPoint(latitude: coordinate.latitude + 0.001, longitude: coordinate.longitude + 0.001)
                return MapArea(points: [point1, point2])
            } else {
                return nil
            }
        }
    }

    public func searchCenter() -> MapPoint? {
        let coordinate = LocationProvider.shared?.location?.coordinate
        let area = PlacesService.shared?.area
        let flag = (self as? NSObject)?.parser.asString(FeatureService.shared?.flag(feature: "auto_complete_area"))
        switch flag {
        case "user":
            if let coordinate = coordinate {
                return MapPoint(latitude: coordinate.latitude, longitude: coordinate.longitude)
            } else {
                return area?.center
            }

        case "map":
            fallthrough
        default:
            if let area = area {
                return area.center
            } else {
                if let coordinate = coordinate {
                    return MapPoint(latitude: coordinate.latitude, longitude: coordinate.longitude)
                } else {
                    return nil
                }
            }
        }
    }

    public func searchRadius() -> Double? {
        let area = PlacesService.shared?.area
        return area?.radius()
    }
}

public class PlacesService {
    public static var shared: PlacesProviderProtocol?
}
