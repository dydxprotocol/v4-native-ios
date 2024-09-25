//
//  SparklineChart.swift
//  dydxViews
//
//  Created by Michael Maguire on 8/14/24.
//

import Foundation
import SwiftUI
import Charts
import DGCharts
import PlatformUI
//import S

struct SparklineView: View {
    let values: [Double]
    
    let isIncreasingPositive = true
    
    private var isIncreasing: Bool { (values.last ?? -Double.infinity) >= (values.first ?? -Double.infinity) }
    private var isPositive: Bool { isIncreasingPositive && isIncreasing || !isIncreasingPositive && !isIncreasing }
    private var color: ThemeColor.SemanticColor { isPositive ? ThemeSettings.positiveColor : ThemeSettings.negativeColor }
    
    private var valuesDomain: ClosedRange<Double> { (values.min() ?? 0)...(values.max() ?? 0) }
    
    var chart: some View {
        Chart(Array(values.enumerated()), id: \.offset) { (offset, element) in
            LineMark(x: .value("", offset),
                     y: .value("", element))
            .lineStyle(StrokeStyle(lineWidth: 1.5))
            .foregroundStyle(color.color.gradient)
            .interpolationMethod(.cardinal)
            .symbolSize(0)
        }
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
        .chartYScale(domain: valuesDomain)
    }

    var body: some View {
        chart
    }
}
