//
//  PriceAxisFormatter.swift
//  dydxPlatformParticles
//
//  Created by Qiang Huang on 11/3/21.
//  Copyright © 2021 dYdX Trading Inc. All rights reserved.
//

import DGCharts
import Foundation
import dydxFormatter

@objc open class PriceAxisFormatter: NSObject, IAxisValueFormatter {
    @objc public var tickSize: String?

    open func stringForValue(_ value: Double, axis _: AxisBase?) -> String {
        return dydxFormatter.shared.localFormatted(number: NSNumber(value: value), size: tickSize) ?? ""
    }
}
