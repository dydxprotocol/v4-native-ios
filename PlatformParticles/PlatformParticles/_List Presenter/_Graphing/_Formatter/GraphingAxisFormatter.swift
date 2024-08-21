//
//  GraphingAxisFormatter.swift
//  PlatformParticles
//
//  Created by Qiang Huang on 9/29/21.
//  Copyright © 2021 dYdX. All rights reserved.
//

import Charts
import Foundation

@objc open class GraphingAxisFormater: NSObject, IAxisValueFormatter {
    open func stringForValue(_ value: Double, axis _: AxisBase?) -> String {
        return ""
    }
}
