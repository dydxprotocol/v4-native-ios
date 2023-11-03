//
//  MapProvider.swift
//  ParticlesKit
//
//  Created by Qiang Huang on 1/25/20.
//  Copyright © 2020 dYdX. All rights reserved.
//

import Utilities

@objc public protocol MapProviderProtocol: NSObjectProtocol {
    @objc var mapRect: MapArea? { get }
}

public class MapProvider {
    public static var shared: MapProviderProtocol?
}
