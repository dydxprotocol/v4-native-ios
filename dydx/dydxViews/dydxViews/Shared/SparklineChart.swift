//
//  SparklineChart.swift
//  dydxViews
//
//  Created by Michael Maguire on 8/14/24.
//

import Foundation
import SwiftUI
import Charts
import PlatformUI

struct SparklineView: View {
    @State var values: [Double]
    
    private var lineChart: some View {
        let chart = LineChartView()
        chart.data = LineChartData()
        chart.xAxis.drawGridLinesEnabled = false
        chart.leftAxis.enabled = false
        chart.rightAxis.enabled = false
        chart.xAxis.enabled = false
        chart.setViewPortOffsets(left: 0, top: 0, right: 0, bottom: 0)
        chart.pinchZoomEnabled = false
        chart.doubleTapToZoomEnabled = false
        // enables dragging the highlighted value indicator
        chart.dragEnabled = false
        chart.legend.enabled = false
        
        let entries = (0..<values.count).map { ChartDataEntry(x: Double($0), y: values[$0]) }
        let dataSet = LineChartDataSet(entries: entries)
        let isPositive = (entries.last?.y ?? -Double.infinity) >= (entries.first?.y ?? -Double.infinity)
        let color = isPositive ? ThemeSettings.positiveColor.uiColor : ThemeSettings.negativeColor.uiColor
                
        //colors
        dataSet.setColor(color)
        
        //shapes
        dataSet.lineWidth = 1.5
        dataSet.lineCapType = .round
        dataSet.mode = .linear
        dataSet.label = nil
        dataSet.drawCirclesEnabled = false
        dataSet.drawValuesEnabled = false
        
        // interactions
        dataSet.highlightEnabled = false
        dataSet.drawHorizontalHighlightIndicatorEnabled = false
                
        chart.data = LineChartData(dataSet: dataSet)
        return chart.swiftUIView
    }
    
    var body: some View {
        lineChart
    }
}
