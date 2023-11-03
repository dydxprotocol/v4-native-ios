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

@objc public class ParticlesLineChartDataEntry: ChartDataEntry, ParticlesChartDataEntryProtocol {
    public var dataSet: Weak<ChartDataSet> = Weak<ChartDataSet>()
    public var notifierDebouncer: Debouncer = Debouncer()

    private var lineData: LinearGraphingObjectProtocol? {
        return model as? LinearGraphingObjectProtocol
    }
    
    override open func sync() {
        if let graphing = model as? LinearGraphingObjectProtocol {
            if let value = graphing.graphingX?.doubleValue {
               x = value
            }
            if let value = graphing.lineY?.doubleValue {
               y = value
            }
        }
    }
}
