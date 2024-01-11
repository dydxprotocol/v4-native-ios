//
//  GraphingPresenter.swift
//  PlatformParticles
//
//  Created by Qiang Huang on 7/21/21.
//  Copyright © 2021 dYdX. All rights reserved.
//

import Charts
import Differ
import ParticlesKit
import UIKit
import UIToolkits
import Utilities

@objc public protocol GraphingDelegate {
    @objc func didLoad(presenter: GraphingPresenter, view: ChartViewBase?, data: ChartData?)
}

open class GraphingPresenter: NSObject {
    @IBOutlet public weak var chartDelegate: ChartViewDelegate? {
        didSet {
            chartView?.delegate = chartDelegate
        }
    }

    @IBOutlet public weak var graphingDelegate: GraphingDelegate?

    @IBOutlet public var xAxisFormatter: IAxisValueFormatter? {
        didSet {
            didSetXAxisFormatter(oldValue: oldValue)
        }
    }

    @IBOutlet public var yAxisFormatter: IAxisValueFormatter? {
        didSet {
            didSetYAxisFormatter(oldValue: oldValue)
        }
    }

    @IBInspectable public var panEnabled: Bool = true
    @IBInspectable public var highlightDistance: Double = 500.0
    @IBInspectable public var drawXAxisLine: Bool = false
    @IBInspectable public var valueFont: UIFont?
    @IBInspectable public var legendFont: UIFont?
    @IBInspectable public var axisFont: UIFont?
    @IBInspectable public var labelColor: UIColor?
    @IBInspectable public var drawXAxisText: Bool = false
    @IBInspectable public var drawYAxisText: Bool = false
    @IBInspectable public var outsideXAxisText: Bool = false
    @IBInspectable public var outsideYAxisText: Bool = false
    @IBInspectable public var drawGrid: Bool = false
    @IBInspectable public var drawBorders: Bool = false
    @IBInspectable public var lineWidth: Int = 1
    @IBOutlet public var view: UIView?
    @IBOutlet public var chartView: ChartViewBase? {
        didSet {
            didSetChartView(oldValue: oldValue)
        }
    }

    @IBOutlet open var presenters: [GraphingListPresenter]? {
        didSet {
            didSetPresenters(oldValue: oldValue)
        }
    }

    private var graphDebouncer: Debouncer = Debouncer()

    open func didSetPresenters(oldValue: [GraphingListPresenter]?) {
        if let oldValue = oldValue {
            for presenter in oldValue {
                changeObservation(from: presenter, to: nil, keyPath: #keyPath(GraphingListPresenter.graphingSet)) { _, _, _, _ in
                }
            }
        }
        if let presenters = presenters {
            for presenter in presenters {
                changeObservation(from: nil, to: presenter, keyPath: #keyPath(GraphingListPresenter.graphingSet)) { [weak self] _, _, _, _ in
                    self?.displayGraphing(animated: false)
                }
            }
        }
    }

    open func didSetXAxisFormatter(oldValue: IAxisValueFormatter?) {
        if xAxisFormatter !== oldValue {
            chartView?.xAxis.valueFormatter = xAxisFormatter
        }
    }

    open func didSetYAxisFormatter(oldValue: IAxisValueFormatter?) {
    }

    open func displayGraphing(animated: Bool) {
        let dataSets = graphingDataSets()
        apply(datasets: dataSets)
        Console.shared.log("Graphing: Applying Data")

//        throttle.debounce()?.run({[weak self] in
//            if let dataSets = self?.graphingDataSets() {
//                self?.apply(datasets: dataSets)
//            }
//        }, delay: 0.0)
    }

    open func graphingDataSets() -> [String: [ChartDataSet]] {
        var datasets = [String: [ChartDataSet]]()

        if let presenters = presenters {
            for presenter in presenters {
                if let dataSet = presenter.graphingSet, dataSet.entries.count > 0 {
                    (dataSet as? ParticlesChartDataSetProtocol)?.presenter.object = self
                    if let candle = dataSet as? CandleChartDataSet {
                        datasets = add(dataSets: datasets, type: "candle", dataSet: candle)
                    } else if let bar = dataSet as? BarChartDataSet {
                        datasets = add(dataSets: datasets, type: "bar", dataSet: bar)
                    } else if let line = dataSet as? LineChartDataSet {
                        datasets = add(dataSets: datasets, type: "line", dataSet: line)
                    } else if let pie = dataSet as? PieChartDataSet {
                        datasets = add(dataSets: datasets, type: "pie", dataSet: pie)
                    }
                }
            }
        }
        return datasets
    }

    open func apply(datasets: [String: [ChartDataSet]]) {
        var chartData = [ChartData]()
        for (key, value) in datasets {
            if let data = data(dataSets: value, type: key) {
                chartData.append(data)
            }
        }
        chartData.first?.setValueFont(valueFont ?? .systemFont(ofSize: 7, weight: .light))
        chartView?.data = chartData.first
        graphingDelegate?.didLoad(presenter: self, view: chartView, data: chartView?.data)
    }

    private func add(dataSets: [String: [ChartDataSet]], type: String, dataSet: ChartDataSet) -> [String: [ChartDataSet]] {
        var dataSets = dataSets
        if var modifying = dataSets[type] {
            modifying.append(dataSet)
            dataSets[type] = modifying
        } else {
            dataSets[type] = [dataSet]
        }
        return dataSets
    }

    internal func data(dataSets: [ChartDataSet], type: String) -> ChartData? {
        switch type {
        case "bar":
            return BarChartData(dataSets: dataSets)

        case "line":
            return LineChartData(dataSets: dataSets)

        case "candle":
            return CandleChartData(dataSets: dataSets)

        case "pie":
            return PieChartData(dataSets: dataSets)

        default:
            return nil
        }
    }

    open func didSetChartView(oldValue: ChartViewBase?) {
        if chartView !== oldValue {
            setup(chartView: chartView)
        }
    }

    open func setup(chartView: ChartViewBase?) {
        chartView?.delegate = chartDelegate

        setupChart(chartView: chartView)
        setupLegend(legend: chartView?.legend)
    }

    open func setupChart(chartView: ChartViewBase?) {
        chartView?.noDataText = ""
        chartView?.chartDescription?.enabled = false
        chartView?.drawMarkers = false
        chartView?.highlightPerTapEnabled = false
        chartView?.maxHighlightDistance = highlightDistance
    }

    open func setupLegend(legend: Legend?) {
        legend?.enabled = false
        legend?.horizontalAlignment = .center
        legend?.verticalAlignment = .top
        legend?.orientation = .horizontal
        legend?.drawInside = true
        legend?.font = legendFont ?? UIFont.systemFont(ofSize: 8)
    }

    open func setupXAxis(xAxis: XAxis?) {
        xAxis?.labelFont = valueFont ?? UIFont.systemFont(ofSize: 8)
        xAxis?.labelTextColor = labelColor ?? UIColor.label
        xAxis?.drawLabelsEnabled = drawXAxisText
        xAxis?.drawGridLinesEnabled = drawGrid
        xAxis?.drawGridLinesBehindDataEnabled = false
        xAxis?.drawLimitLinesBehindDataEnabled = false
        xAxis?.valueFormatter = xAxisFormatter
        xAxis?.labelPosition = outsideXAxisText ? .bottom : .bottomInside
        xAxis?.valueFormatter = xAxisFormatter
        xAxis?.drawAxisLineEnabled = drawXAxisLine
        xAxis?.forceLabelsEnabled = true
        xAxis?.granularityEnabled = true
        xAxis?.centerAxisLabelsEnabled = true
    }
}
