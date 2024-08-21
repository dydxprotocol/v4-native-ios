//
//  PieGraphingPresenter.swift
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

open class PieGraphingPresenter: GraphingPresenter {
    public var pieChartView: PieChartView? {
        return chartView as? PieChartView
    }

    override open func setupChart(chartView: ChartViewBase?) {
        super.setupChart(chartView: chartView)
        pieChartView?.drawHoleEnabled = true
        pieChartView?.holeRadiusPercent = 0.7
        pieChartView?.drawMarkers = true
        pieChartView?.drawEntryLabelsEnabled = drawXAxisText
        pieChartView?.drawCenterTextEnabled = false
    }
}
