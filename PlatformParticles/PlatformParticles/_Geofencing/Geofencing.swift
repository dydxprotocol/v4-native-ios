//
//  Geofencing.swift
//  PlatformParticles
//
//  Created by Qiang Huang on 10/7/19.
//  Copyright © 2019 Qiang Huang. All rights reserved.
//

import ParticlesKit

@objc public class Geofencing: DictionaryEntity {
    @objc public dynamic var address: String? {
        get {
            return parser.asString(data?["address"])
        }
        set {
            willChangeValue(forKey: "address")
            force.data?["address"] = newValue
            didChangeValue(forKey: "address")
        }
    }

    @objc public dynamic var unit: String? {
        get {
            return parser.asString(data?["unit"])
        }
        set {
            willChangeValue(forKey: "unit")
            force.data?["unit"] = newValue
            didChangeValue(forKey: "unit")
        }
    }

    @objc public dynamic var lat: NSNumber? {
        get {
            return parser.asNumber(data?["lat"])
        }
        set {
            willChangeValue(forKey: "lat")
            force.data?["lat"] = newValue
            didChangeValue(forKey: "lat")
        }
    }

    @objc public dynamic var lng: NSNumber? {
        get {
            return parser.asNumber(data?["lng"])
        }
        set {
            willChangeValue(forKey: "lng")
            force.data?["lng"] = newValue
            didChangeValue(forKey: "lng")
        }
    }

    @objc public dynamic var radius: NSNumber? {
        get {
            return parser.asNumber(data?["radius"])
        }
        set {
            willChangeValue(forKey: "radius")
            force.data?["radius"] = newValue
            didChangeValue(forKey: "radius")
        }
    }

    @objc public dynamic var token: String? {
        get {
            return parser.asString(data?["token"])
        }
        set {
            willChangeValue(forKey: "token")
            force.data?["token"] = newValue
            didChangeValue(forKey: "token")
        }
    }
}
