//
//  GraphingProtocols.swift
//  ParticlesKit
//
//  Created by Qiang Huang on 9/29/21.
//  Copyright © 2021 dYdX. All rights reserved.
//

import Foundation

@objc public protocol CandleStickListProviderProtocol: NSObjectProtocol {
    var maxVolume: NSNumber? { get }
    var lowPrice: NSNumber? { get }
    var highPrice: NSNumber? { get }
}
