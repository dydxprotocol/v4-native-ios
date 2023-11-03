//
//  PercentAxisFormatter.swift
//  dydxPlatformParticles
//
//  Created by Qiang Huang on 11/3/21.
//  Copyright © 2021 dYdX Trading Inc. All rights reserved.
//

import Charts
import dydxFormatter
import Foundation

@objc open class PercentAxisFormatter: NSObject, IAxisValueFormatter {
    open func stringForValue(_ value: Double, axis _: AxisBase?) -> String {
        return dydxFormatter.shared.percent(number: NSNumber(value: value), digits: 4) ?? ""
    }
}
