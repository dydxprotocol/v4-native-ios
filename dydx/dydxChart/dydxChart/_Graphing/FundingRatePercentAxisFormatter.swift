//
//  FundingRatePercentAxisFormatter.swift
//  dydxPlatformParticles
//
//  Created by Qiang Huang on 11/19/21.
//  Copyright © 2021 dYdX Trading Inc. All rights reserved.
//

import DGCharts
import dydxFormatter

@objc public enum FundingDuration: Int {
    case oneHour
    case eightHour
    case annualized
}

@objc open class FundingRatePercentAxisFormatter: PercentAxisFormatter {
    public var duration: FundingDuration = .oneHour

    override open func stringForValue(_ value: Double, axis _: AxisBase?) -> String {

        switch duration {
        case .oneHour:
            let digits = 4
            return dydxFormatter.shared.percent(number: NSNumber(value: value.round(to: digits)), digits: digits) ?? ""
        case .eightHour:
            let adjusted = value * 8
            let digits = 3
            return dydxFormatter.shared.percent(number: NSNumber(value: adjusted.round(to: digits)), digits: digits) ?? ""
        case .annualized:
            let adjusted = value * 24 * 365
            let digits = 2
            return dydxFormatter.shared.percent(number: NSNumber(value: adjusted.round(to: digits)), digits: digits) ?? ""
        }
    }
}
