//
//  LocatorService.swift
//  ParticlesKit
//
//  Created by Qiang Huang on 9/15/20.
//  Copyright © 2020 dYdX. All rights reserved.
//

import Foundation

@objc public protocol LocatorProviderProtocol: NSObjectProtocol {
    @objc var running: Bool { get set }
    @objc var shouldBeRunning: Bool { get set }
    func mark(tag: String)
}

public class LocatorService {
    public static var shared: LocatorProviderProtocol?
}
