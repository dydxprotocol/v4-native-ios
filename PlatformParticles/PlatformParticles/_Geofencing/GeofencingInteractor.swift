//
//  GeofencingInteractor.swift
//  PlatformParticles
//
//  Created by Qiang Huang on 10/7/19.
//  Copyright © 2019 Qiang Huang. All rights reserved.
//

import CoreLocation
import ParticlesKit
import UserNotifications
import Utilities

@objc public final class GeofencingInteractor: DataPoolInteractor, RegionMonitorProtocol {
    @objc public var current: Set<MapPoint>?
    @objc public var radius: Double = 200
    @objc public var text: String = ""

    private var locationManager: CLLocationManager?

    public init(radius: Double, text: String) {
        self.radius = radius
        self.text = text
        super.init()
        locationManager = LocationProvider.shared?.locationManager
    }

    public func monitor(lat: Double, lng: Double, callbackUrl: String?) {
        if CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) && fence(lat: lat, lng: lng) == nil {
            let fence = Geofencing()
            fence.lat = NSNumber(value: lat)
            fence.lng = NSNumber(value: lng)
            fence.radius = NSNumber(value: min(radius, locationManager?.maximumRegionMonitoringDistance ?? 1000.0))
            fence.token = UUID().uuidString

            let circular = CLCircularRegion(center: CLLocationCoordinate2D(latitude: lat, longitude: lng), radius: fence.radius?.doubleValue ?? 0.0, identifier: fence.token ?? "")
            circular.notifyOnEntry = true
            circular.notifyOnExit = false
            locationManager?.startMonitoring(for: circular)

            UNUserNotificationCenter.current().getNotificationSettings {[weak self] settings in
                if let self = self, settings.authorizationStatus == .authorized {
                    let content = UNMutableNotificationContent()
                    content.title = "Arrived"
                    content.body = self.text
                    if let callbackUrl = callbackUrl {
                        content.userInfo = ["link": callbackUrl]
                    }

//                    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
                    let trigger = UNLocationNotificationTrigger(region: circular, repeats: false)
                    let request = UNNotificationRequest(identifier: fence.token ?? "",
                                                        content: content, trigger: trigger)
                    UNUserNotificationCenter.current().add(request) { error in
                        if let error = error {
                            Console.shared.log("\(error)")
                        }
                    }
                }
            }
        }
    }

    public func clear() {
        if let regions = locationManager?.monitoredRegions {
            for region in regions {
                locationManager?.stopMonitoring(for: region)
            }
        }
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        data = nil
        current = nil
    }

    public func enter(lat: Double, lng: Double) {
        if current?.first(where: { (point) -> Bool in
            point.latitude == lat && point.longitude == lng
        }) == nil {
            let point = MapPoint(latitude: lat, longitude: lng)
            if current == nil {
                current = [point]
            } else {
                willChangeValue(forKey: "current")
                current?.insert(MapPoint(latitude: lat, longitude: lng))
                didChangeValue(forKey: "current")
            }
        }
    }

    public func exit(lat: Double, lng: Double) {
        if let current = current {
            for point in current {
                if point.latitude == lat && point.longitude == lng {
                    self.current?.remove(point)
                }
            }
        }
    }

    public var fences: [String: Geofencing]? {
        return data as? [String: Geofencing]
    }

    public override init() {
        super.init(key: "geofencing", default: nil)
    }

    public override func createLoader() -> LoaderProtocol? {
        return LoaderProvider.shared?.loader(tag: "geofencing", cache: self)
    }

    public override func entity(from data: [String: Any]?) -> ModelObjectProtocol? {
        if let token = parser.asString(data?["token"]) {
            return fences?[token]
        }
        return nil
    }

    private func fence(lat: Double, lng: Double) -> Geofencing? {
        return fences?.first(where: { (arg0) -> Bool in
            let (_, value) = arg0
            return value.lat?.doubleValue == lat && value.lng?.doubleValue == lng
        })?.value
    }

    private func fence(token: String) -> Geofencing? {
        return fences?[token]
    }

    private func add(fence: Geofencing) {
        if let token = fence.token {
            if data == nil {
                data = [:]
            }
            data?[token] = fence
        }
        save()
    }

    private func remove(fence: Geofencing) {
        if let token = fence.token {
            data?.removeValue(forKey: token)
        }
        save()
    }

    private func remove(lat: Double, lng: Double) {
        if let fence = fence(lat: lat, lng: lng) {
            remove(fence: fence)
        }
    }

    private func remove(token: String) {
        if let fence = fence(token: token) {
            remove(fence: fence)
        }
    }

    public override func save() {
        loader?.save(object: data)
    }
}
