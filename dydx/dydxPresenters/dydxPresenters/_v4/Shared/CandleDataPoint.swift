//
//  CandleDataPoint.swift
//  dydxPresenters
//
//  Created by Rui Huang on 10/9/22.
//

import Foundation
import PlatformParticles
import ParticlesKit
import Abacus
import Utilities
import dydxChart

final class CandleDataPoint: DictionaryEntity, LinearGraphingObjectProtocol, CandleGraphingObjectProtocol, BarGraphingObjectProtocol {

    // MARK: BarGraphingObjectProtocol

    private(set) var barY: NSNumber?

    // MARK: CandleGraphingObjectProtocol

    private(set) var candleLabel: String?
    private(set) var candleOpen: NSNumber?
    private(set) var candleClose: NSNumber?
    private(set) var candleHigh: NSNumber?
    private(set) var candleLow: NSNumber?

    // MARK: LinearGraphingObjectProtocol

    private(set) var lineY: NSNumber?

    private(set) var graphingX: NSNumber?

    private(set) var marketCandle: MarketCandle?

    private var resolution: CandleResolution = .ONEHOUR

    init(candle: MarketCandle, resolution: CandleResolution) {
        self.marketCandle = candle
        self.resolution = resolution
        super.init()

        lineY = NSNumber(value: candle.close)

        if let anchor = GraphingAnchor.shared?.date {
            let timeInterval =  Date(milliseconds: candle.startedAtMilliseconds).timeIntervalSince(anchor)
            let divided = timeInterval / unitInterval + 2500.0
            graphingX = NSNumber(value: divided)
        } else {
            graphingX = nil
        }

        candleLow = NSNumber(value: candle.low)
        candleHigh = NSNumber(value: candle.high)
        candleOpen = NSNumber(value: candle.open)
        candleClose = NSNumber(value: candle.close)

        barY = NSNumber(value: candle.usdVolume)
    }

    required init() {}

    override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? CandleDataPoint else { return false }

        return barY == object.barY &&
            candleLabel == object.candleLabel &&
            candleOpen == object.candleOpen &&
            candleClose == object.candleClose &&
            candleHigh == object.candleHigh &&
            candleLow == object.candleLow &&
            graphingX == object.graphingX &&
            lineY == object.lineY &&
            resolution == object.resolution &&
            marketCandle == object.marketCandle
    }

    private lazy var unitInterval: Double = {
        switch resolution {
        case .FIVEMINS:
            return 60.0 * 5

        case .FIFTEENMINS:
            return 60.0 * 15

        case .THIRTYMINS:
            return 60.0 * 30

        case .ONEHOUR:
            return 60.0 * 60

        case .FOURHOURS:
            return 60.0 * 60 * 4

        case .ONEDAY:
            return 60.0 * 60 * 24

        case .ONEMIN:
            fallthrough
        default:
            return 60.0
        }
    }()
}
