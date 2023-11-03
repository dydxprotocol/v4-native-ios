//
//  HistoricalPNLDataPoint.swift
//  dydxPresenters
//
//  Created by Rui Huang on 1/9/23.
//

import Foundation
import PlatformParticles
import ParticlesKit
import Abacus
import Utilities

final class HistoricalPNLDataPoint: DictionaryEntity, LinearGraphingObjectProtocol {

    // MARK: LinearGraphingObjectProtocol

    private(set) var lineY: NSNumber?

    private(set) var graphingX: NSNumber?

    private(set) var historicalPNL: SubaccountHistoricalPNL?

    init(pnl: SubaccountHistoricalPNL) {
        self.historicalPNL = pnl

        lineY = NSNumber(value: pnl.equity)

        if let anchor = GraphingAnchor.shared?.date {
            let effectiveDate = Date(milliseconds: pnl.createdAtMilliseconds)
            let timeInterval = effectiveDate.timeIntervalSince(anchor)
            let divided = timeInterval / Self.unitInterval() + 2500.0
            graphingX = NSNumber(value: divided)
        }
    }

    required init() {}

    private static func unitInterval() -> Double {
        return 60.0 * 60
    }
}
