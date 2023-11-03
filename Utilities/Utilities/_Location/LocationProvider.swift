//
//  LocationProvider.swift
//  Utilities
//
//  Created by Qiang Huang on 8/18/19.
//  Copyright © 2019 Qiang Huang. All rights reserved.
//

import CoreLocation
import Foundation

@objc public protocol LocationProviderProtocol: NSObjectProtocol {
    @objc var location: CLLocation? { get }
    @objc var locationManager: CLLocationManager? { get }
}

public class LocationProvider {
    public static var shared: LocationProviderProtocol?
}
