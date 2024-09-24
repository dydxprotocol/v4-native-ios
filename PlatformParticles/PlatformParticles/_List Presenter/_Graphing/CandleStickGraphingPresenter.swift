//
//  CandleStickGraphingPresenter.swift
//  PlatformParticles
//
//  Created by Qiang Huang on 3/6/21.
//  Copyright © 2021 dYdX. All rights reserved.
//

import DGCharts
import Differ
import ParticlesKit
import UIToolkits
import Utilities

open class CandleStickGraphingPresenter: GraphingPresenter {
    public var candleChartView: CandleStickChartView? {
        return chartView as? CandleStickChartView
    }
    
    open override func setup(chartView: ChartViewBase?) {
        super.setup(chartView: chartView)
        
        setupXAxis(xAxis: chartView?.xAxis)
        setupLeftAxis(leftAxis: candleChartView?.leftAxis)
        setupRightAxis(rightAxis: candleChartView?.rightAxis)
    }
    
    open override func setupChart(chartView: ChartViewBase?) {
        super.setupChart(chartView: chartView)
        
        candleChartView?.drawBordersEnabled = drawBorders || drawGrid
        candleChartView?.drawGridBackgroundEnabled = false
        candleChartView?.drawMarkers = false
        
        candleChartView?.setScaleEnabled(true)
        
        candleChartView?.dragEnabled = true
        candleChartView?.pinchZoomEnabled = true
        candleChartView?.renderer = CandleStickGraphingRenderer(view: candleChartView!, minValue: 0, maxValue: 90000)
    }
    
    open override func setupXAxis(xAxis: XAxis?) {
        super.setupXAxis(xAxis: xAxis)
    }
    
    open func setupLeftAxis(leftAxis: YAxis?) {
        leftAxis?.enabled = false
        leftAxis?.axisMinimum = 0.0
    }

    open func setupRightAxis(rightAxis: YAxis?) {
        rightAxis?.drawAxisLineEnabled = true
        rightAxis?.drawLabelsEnabled = drawYAxisText
        rightAxis?.drawGridLinesEnabled = drawGrid
        rightAxis?.drawLimitLinesBehindDataEnabled = false
        rightAxis?.drawGridLinesBehindDataEnabled = false
        rightAxis?.labelTextColor = labelColor ?? UIColor.label
        rightAxis?.axisMinimum = 0.0
    }

    override open func setupLegend(legend: Legend?) {
        super.setupLegend(legend: legend)
    }
}
