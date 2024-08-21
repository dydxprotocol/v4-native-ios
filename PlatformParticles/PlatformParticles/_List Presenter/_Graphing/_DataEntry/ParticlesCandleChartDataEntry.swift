//
//  ParticlesCandleChartDataEntry.swift
//  PlatformParticles
//
//  Created by Qiang Huang on 10/8/21.
//  Copyright © 2021 dYdX Trading Inc. All rights reserved.
//

import Charts
import ParticlesKit
import Utilities

@objc public class ParticlesCandleChartDataEntry: CandleChartDataEntry, ParticlesChartDataEntryProtocol {
    public var dataSet: Weak<ChartDataSet> = Weak<ChartDataSet>()
    public var notifierDebouncer: Debouncer = Debouncer()

    private var candleData: CandleGraphingObjectProtocol? {
        return model as? CandleGraphingObjectProtocol
    }

    override open func sync() {
        if let graphing = model as? CandleGraphingObjectProtocol {
            if let value = graphing.graphingX?.doubleValue {
                x = value
            }
            if let value = graphing.candleHigh?.doubleValue {
                high = value
            }
            if let value = graphing.candleLow?.doubleValue {
                low = value
            }
            if let value = graphing.candleOpen?.doubleValue {
                open = value
            }
            if let value = graphing.candleClose?.doubleValue {
                close = value
                y = value
            }
        }
    }
}
