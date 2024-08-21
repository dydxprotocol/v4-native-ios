//
//  OrderbookLineDataPoint.swift
//  dydxPresenters
//
//  Created by Rui Huang on 10/10/22.
//

import Foundation
import PlatformParticles
import ParticlesKit
import Abacus
import Utilities

final class OrderbookLineDataPoint: DictionaryEntity, LinearGraphingObjectProtocol {
    enum Side {
        case bids, asks
    }

    // MARK: LinearGraphingObjectProtocol

    private(set) var lineY: NSNumber?

    private(set) var graphingX: NSNumber?

    private(set) var orderbookLine: OrderbookLine?
    private(set) var side: Side = .asks

    init(line: OrderbookLine, side: Side) {
        self.orderbookLine = line
        self.side = side

        if let depth = line.depth?.doubleValue {
            lineY = NSNumber(value: depth)
        }

        graphingX = NSNumber(value: line.price)
    }

    required init() {}
}
