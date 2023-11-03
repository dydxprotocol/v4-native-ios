//
//  LocationPermission.swift
//  Utilities
//
//  Created by Qiang Huang on 7/18/20.
//  Copyright © 2020 Qiang Huang. All rights reserved.
//

import CoreLocation
import Foundation

@objc open class LocationPermission: PrivacyPermission, CLLocationManagerDelegate {
    private static var _shared: LocationPermission?
    public static var shared: LocationPermission {
        get {
            if _shared == nil {
                _shared = LocationPermission()
            }
            return _shared!
        }
        set {
            _shared = newValue
        }
    }

    public var always: Bool = false

    override public func awakeAfter(using aDecoder: NSCoder) -> Any? {
        if type(of: self)._shared == nil {
            type(of: self)._shared = super.awakeAfter(using: aDecoder) as? LocationPermission
        }
        return type(of: self).shared
    }

    override public var requestMessage: String? {
        return "Please enable Location Service in your app settings."
    }

    public var locationManager: CLLocationManager? {
        didSet {
            if locationManager !== oldValue {
                oldValue?.delegate = nil
                locationManager?.delegate = self
            }
        }
    }

    override public func currentAuthorizationStatus(completion: @escaping PermissionStatusCompletionHandler) {
        let authorizationStatus = CLLocationManager.authorizationStatus()
        var status: EPrivacyPermission = .notDetermined
        var background: NSNumber?
        switch authorizationStatus {
        case .notDetermined:
            status = .notDetermined

        case .restricted:
            status = .restricted

        case .authorizedAlways:
            status = .authorized
            background = NSNumber(value: true)

        case .authorizedWhenInUse:
            status = .authorized
            if always {
                background = NSNumber(value: false)
            }

        default:
            status = .denied
        }
        completion(status, background)
    }

    override open func promptToAuthorize() {
        if locationManager == nil {
            locationManager = CLLocationManager()
        }
        locationManager?.requestWhenInUseAuthorization()
    }

    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        refreshStatus()
    }
}
