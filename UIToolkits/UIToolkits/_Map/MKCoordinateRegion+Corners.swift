//
//  MKCoordinateRegion+Corners.swift
//  UIToolkits
//
//  Created by Qiang Huang on 7/23/19.
//  Copyright © 2019 dYdX. All rights reserved.
//

import MapKit

public extension MKCoordinateRegion {
    var northWest: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: center.latitude + span.latitudeDelta / 2, longitude: center.longitude - span.longitudeDelta / 2)
    }

    var northEast: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: center.latitude + span.latitudeDelta / 2, longitude: center.longitude + span.longitudeDelta / 2)
    }

    var southWest: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: center.latitude - span.latitudeDelta / 2, longitude: center.longitude - span.longitudeDelta / 2)
    }

    var southEast: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: center.latitude - span.latitudeDelta / 2, longitude: center.longitude + span.longitudeDelta / 2)
    }

    func contains(coordinate: CLLocationCoordinate2D) -> Bool {
        let center = self.center
        let span = self.span

        return cos((center.latitude - coordinate.latitude) * .pi / 180.0) > cos(span.latitudeDelta / 2.0 * .pi / 180.0) && cos((center.longitude - coordinate.longitude) * .pi / 180.0) > cos(span.longitudeDelta / 2.0 * .pi / 180.0)
    }
}
