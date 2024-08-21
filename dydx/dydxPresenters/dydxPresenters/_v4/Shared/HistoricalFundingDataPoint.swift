//
//  HistoricalFundingDataPoint.swift
//  dydxPresenters
//
//  Created by Rui Huang on 10/11/22.
//

import Foundation
import PlatformParticles
import ParticlesKit
import Abacus
import Utilities

final class HistoricalFundingDataPoint: DictionaryEntity, LinearGraphingObjectProtocol {

    // MARK: LinearGraphingObjectProtocol

    private(set) var lineY: NSNumber?

    private(set) var graphingX: NSNumber?

    private(set) var historicalFunding: MarketHistoricalFunding?

    init(funding: MarketHistoricalFunding) {
        self.historicalFunding = funding

        lineY = NSNumber(value: funding.rate)

        if let anchor = GraphingAnchor.shared?.date {
            let effectiveDate = Date(milliseconds: funding.effectiveAtMilliseconds)
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
