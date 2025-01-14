//
//  dydxLineChartView.swift
//  dydxViews
//
//  Created by Rui Huang on 24/12/2024.
//

import Foundation
import PlatformUI
import SwiftUI
import Utilities
import Charts
import Combine
import dydxChart
import dydxFormatter

public class dydxLineChartViewModel: PlatformViewModel {
    public struct Entry: Equatable {
        public let date: Double
        public let value: Double

        public init(date: Double, value: Double) {
            self.date = date
            self.value = value
        }
    }

    @Published public var valueLowerBoundOffset: Double = 0
    @Published public var valueUpperBoundOffset: Double = 0
    @Published public var showYLabels: Bool = true

    @Published public var entries: [Entry] = []
    fileprivate var isPositive: Bool { (entries.last?.value ?? -Double.infinity) >= (entries.first?.value ?? -Double.infinity) }
    fileprivate var lineColor: Color { isPositive ? ThemeSettings.positiveColor.color : ThemeSettings.negativeColor.color }
    fileprivate var datesDomain: ClosedRange<Double> {
        (entries.map(\.date).min() ?? 0)...(entries.map(\.date).max() ?? 0)
    }
    fileprivate var valuesDomain: ClosedRange<Double> {
        ((entries.map(\.value).min() ?? 0) - valueLowerBoundOffset)...((entries.map(\.value).max() ?? 0) + valueUpperBoundOffset)
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] _  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            return AnyView(chart)
        }
    }

    private var chart: some View {
        Chart(entries, id: \.date) { entry in
            LineMark(x: .value("", entry.date),
                     y: .value("", entry.value))
            .lineStyle(StrokeStyle(lineWidth: 2))
            .foregroundStyle(self.lineColor.gradient)
            .interpolationMethod(.monotone)
            .symbolSize(0)
            // adds gradient shading
            AreaMark(
                x: .value("", entry.date),
                yStart: .value("", self.valuesDomain.lowerBound),
                yEnd: .value("", entry.value)
            )
            .foregroundStyle(self.chartGradient)
        }
        .chartXAxis(.hidden)
        .chartYAxis {
            if showYLabels {
                AxisMarks(values: .automatic) {
                    let value = dydxFormatter.shared.condensedDollar(number: $0.as(Double.self), digits: 1)
                    AxisValueLabel {
                        if let value {
                            Text(value)
                        }
                    }
                    .font(Font.system(size: 8))
                    .foregroundStyle(ThemeColor.SemanticColor.textTertiary.color)
                }
            }
        }
        .chartXScale(domain: .automatic(includesZero: false))
        .chartYScale(domain: .automatic(includesZero: false))
    }

    private var chartGradient: Gradient {
        Gradient(colors: [lineColor.opacity(0.3),
                          lineColor.opacity(0)])
    }
}
