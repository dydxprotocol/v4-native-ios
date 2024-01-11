//
//  LineGraphingPresenter.swift
//  PlatformParticles
//
//  Created by Qiang Huang on 3/6/21.
//  Copyright © 2021 dYdX. All rights reserved.
//

import Charts
import Differ
import ParticlesKit
import UIToolkits
import Utilities

open class LineGraphingPresenter: GraphingPresenter {
    @IBInspectable public var doubleTapToZoomEnabled: Bool = false
    @IBInspectable public var drawFilled: Bool = false
    public var lineChartView: LineChartView? {
        return chartView as? LineChartView
    }

    override open func setup(chartView: ChartViewBase?) {
        super.setup(chartView: chartView)

        setupXAxis(xAxis: chartView?.xAxis)
        setupLeftAxis(leftAxis: lineChartView?.leftAxis)
        setupRightAxis(rightAxis: lineChartView?.rightAxis)
    }

    override open func setupChart(chartView: ChartViewBase?) {
        super.setupChart(chartView: chartView)

        lineChartView?.doubleTapToZoomEnabled = doubleTapToZoomEnabled
        lineChartView?.autoScaleMinMaxEnabled = true
        lineChartView?.highlightPerDragEnabled = true
        lineChartView?.drawBordersEnabled = drawBorders || drawGrid
        lineChartView?.drawGridBackgroundEnabled = false

        lineChartView?.dragEnabled = panEnabled
        lineChartView?.setScaleEnabled(true)
    }

    override open func setupXAxis(xAxis: XAxis?) {
        super.setupXAxis(xAxis: xAxis)

        lineChartView?.xAxis.drawLabelsEnabled = drawXAxisText
        lineChartView?.xAxis.drawGridLinesEnabled = drawGrid
        lineChartView?.xAxis.labelTextColor = labelColor ?? UIColor.label
    }

    open func setupLeftAxis(leftAxis: YAxis?) {
        leftAxis?.drawLabelsEnabled = drawYAxisText
        leftAxis?.drawGridLinesEnabled = drawGrid
        leftAxis?.drawLimitLinesBehindDataEnabled = false
        leftAxis?.drawGridLinesBehindDataEnabled = false
        leftAxis?.labelTextColor = labelColor ?? UIColor.label
        leftAxis?.labelPosition = outsideYAxisText ? .outsideChart : .insideChart
        leftAxis?.valueFormatter = yAxisFormatter
        leftAxis?.drawAxisLineEnabled = false
        leftAxis?.drawZeroLineEnabled = true
        leftAxis?.zeroLineDashLengths = [4.0]
    }

    open func setupRightAxis(rightAxis: YAxis?) {
        rightAxis?.enabled = false
    }

    override open func didSetYAxisFormatter(oldValue: IAxisValueFormatter?) {
        if yAxisFormatter !== oldValue {
            lineChartView?.leftAxis.valueFormatter = yAxisFormatter
        }
    }

    override open func setupLegend(legend: Legend?) {
        super.setupLegend(legend: legend)
    }
}
