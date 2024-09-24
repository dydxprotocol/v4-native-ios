//
//  ParticlesCandleChartDataEntry.swift
//  PlatformParticles
//
//  Created by Qiang Huang on 10/8/21.
//  Copyright © 2021 dYdX Trading Inc. All rights reserved.
//

import DGCharts
import ParticlesKit
import Utilities

@objc public class ParticlesBarChartDataEntry: BarChartDataEntry, ParticlesChartDataEntryProtocol {
    public var dataSet: Weak<ChartDataSet> = Weak<ChartDataSet>()
    public var notifierDebouncer: Debouncer = Debouncer()
    
    private var barData: BarGraphingObjectProtocol? {
        return model as? BarGraphingObjectProtocol
    }

    override open func sync() {
        if let graphing = model as? BarGraphingObjectProtocol {
            if let value = graphing.graphingX?.doubleValue {
               x = value
            }
            if let value = graphing.barY?.doubleValue {
               y = value
            }
        }
    }
}
