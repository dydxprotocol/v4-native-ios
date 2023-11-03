//
//  RegionMonitor.swift
//  Utilities
//
//  Created by Qiang Huang on 1/19/20.
//  Copyright © 2020 dYdX. All rights reserved.
//

import CoreLocation
import Foundation

@objc public protocol RegionMonitorProtocol: NSObjectProtocol {
    @objc var current: Set<MapPoint>? { get set }

    func monitor(lat: Double, lng: Double, callbackUrl: String?)
    func clear()

    func enter(lat: Double, lng: Double)
    func exit(lat: Double, lng: Double)
}

public class RegionMonitor {
    public static var shared: RegionMonitorProtocol?
}
