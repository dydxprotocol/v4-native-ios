//
//  CombinedGraphingPresenter.swift
//  CombinedGraphingPresenter
//
//  Created by Qiang Huang on 8/16/21.
//  Copyright © 2021 dYdX. All rights reserved.
//

import Charts
import Differ
import ParticlesKit
import UIToolkits
import Utilities

open class CombinedGraphingPresenter: GraphingPresenter {
    private var candleStickList: CandleStickListProviderProtocol?

    public var combinedChartView: CombinedChartView? {
        return chartView as? CombinedChartView
    }

    override open func didSetPresenters(oldValue: [GraphingListPresenter]?) {
        super.didSetPresenters(oldValue: oldValue)
        candleStickList = presenters?.first(where: { listPresenter in
            listPresenter is CandleStickListProviderProtocol
        }) as? CandleStickListProviderProtocol
    }

    override open func setup(chartView: ChartViewBase?) {
        super.setup(chartView: chartView)
        (chartView as? BarLineChartViewBase)?.autoScaleMinMaxEnabled = false

        setupXAxis(xAxis: chartView?.xAxis)
        setupLeftAxis(leftAxis: combinedChartView?.leftAxis)
        setupRightAxis(rightAxis: combinedChartView?.rightAxis)

        combinedChartView?.scaleXEnabled = true
        combinedChartView?.scaleYEnabled = false
        combinedChartView?.highlightPerDragEnabled = true
    }

    override open func setupXAxis(xAxis: XAxis?) {
        super.setupXAxis(xAxis: xAxis)
    }

    open func setupLeftAxis(leftAxis: YAxis?) {
        leftAxis?.enabled = true
        leftAxis?.drawLabelsEnabled = drawYAxisText
        leftAxis?.drawGridLinesEnabled = drawGrid
        leftAxis?.drawLimitLinesBehindDataEnabled = false
        leftAxis?.drawGridLinesBehindDataEnabled = false
        leftAxis?.labelTextColor = labelColor ?? UIColor.label
        leftAxis?.spaceBottom = 0.8
        leftAxis?.labelPosition = outsideYAxisText ? .outsideChart : .insideChart
        leftAxis?.drawAxisLineEnabled = false
        leftAxis?.valueFormatter = yAxisFormatter
    }

    open func setupRightAxis(rightAxis: YAxis?) {
        rightAxis?.enabled = true
        rightAxis?.drawLabelsEnabled = false
        rightAxis?.drawGridLinesEnabled = drawGrid
        rightAxis?.drawLimitLinesBehindDataEnabled = false
        rightAxis?.drawGridLinesBehindDataEnabled = false
        rightAxis?.labelTextColor = labelColor ?? UIColor.label
        rightAxis?.drawAxisLineEnabled = false
        rightAxis?.labelPosition = outsideYAxisText ? .outsideChart : .insideChart
        rightAxis?.axisMinimum = 0.0
        rightAxis?.spaceTop = 9
    }

    override open func setupLegend(legend: Legend?) {
        super.setupLegend(legend: legend)
    }

    override open func graphingDataSets() -> [String: [ChartDataSet]] {
        var result = super.graphingDataSets()
        var hasCandles = false
        for (key, datasets) in result {
            for dataset in datasets {
                switch key {
                case "candle":
                    fallthrough
                case "line":
                    hasCandles = true
                    dataset.axisDependency = .left

                case "bar":
                    dataset.axisDependency = .right

                default:
                    break
                }
            }
        }
        if !hasCandles {
            result.removeAll()
        }
        return result
    }

    override open func apply(datasets: [String: [ChartDataSet]]) {
        var chartData = [ChartData]()
        for (key, value) in datasets {
            if let data = data(dataSets: value, type: key) {
                chartData.append(data)
            }
        }
        if chartData.count > 0 {
            if chartData.count == 1 {
                chartData.first?.setValueFont(.systemFont(ofSize: 7, weight: .light))
                chartView?.data = chartData.first
            } else {
                let combinedChartData = CombinedChartData()
                if let candleDataSets = datasets["candle"] as? [CandleChartDataSet] {
                    combinedChartData.candleData = CandleChartData(dataSets: candleDataSets)
                }
                if let lineDataSets = datasets["line"] as? [LineChartDataSet] {
                    combinedChartData.lineData = LineChartData(dataSets: lineDataSets)
                }
                if let barDataSets = datasets["bar"] as? [BarChartDataSet] {
                    combinedChartData.barData = BarChartData(dataSets: barDataSets)
                }
                combinedChartData.setValueFont(valueFont ?? .systemFont(ofSize: 7, weight: .light))
                chartView?.data = combinedChartData
            }
            chartView?.xAxis.setLabelCount(6, force: true)
            combinedChartView?.setVisibleXRange(minXRange: 8, maxXRange: 40)
            combinedChartView?.moveViewToX(10000)
            combinedChartView?.setVisibleXRange(minXRange: 8, maxXRange: 160)
            combinedChartView?.scale()
        } else {
            chartView?.clear()
        }
    }
}
