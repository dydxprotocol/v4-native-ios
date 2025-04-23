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
    @Published public var dataPointSelected: ((Entry?) -> Void)?

    @Published public var backgroundColor: ThemeColor.SemanticColor = .transparent

    @Published public var entries: [Entry] = []
    fileprivate var isPositive: Bool { (entries.last?.value ?? -Double.infinity) >= (entries.first?.value ?? -Double.infinity) }
    fileprivate var lineColor: Color { isPositive ? ThemeSettings.positiveColor.color : ThemeSettings.negativeColor.color }
    fileprivate var datesDomain: ClosedRange<Double> {
        (entries.map(\.date).min() ?? 0)...(entries.map(\.date).max() ?? 0)
    }
    fileprivate var valuesDomain: ClosedRange<Double> {
        ((entries.map(\.value).min() ?? 0) - valueLowerBoundOffset)...((entries.map(\.value).max() ?? 0) + valueUpperBoundOffset)
    }

    public init(valueLowerBoundOffset: Double = 0, valueUpperBoundOffset: Double = 0, showYLabels: Bool = true, dataPointSelected: ((dydxLineChartViewModel.Entry?) -> Void)? = nil, backgroundColor: ThemeColor.SemanticColor = .transparent, entries: [dydxLineChartViewModel.Entry] = []) {
        self.valueLowerBoundOffset = valueLowerBoundOffset
        self.valueUpperBoundOffset = valueUpperBoundOffset
        self.showYLabels = showYLabels
        self.dataPointSelected = dataPointSelected
        self.backgroundColor = backgroundColor
        self.entries = entries
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            return AnyView(dydxLineChartView(model: self, parentStyle: style, styleKey: nil))
        }
    }
}

private struct dydxLineChartView: View {
    @ObservedObject private var model: dydxLineChartViewModel
    @ObservedObject public var themeSettings = ThemeSettings.shared

    private let parentStyle: ThemeStyle
    private let styleKey: String?

    @State private var selectedPoint: dydxLineChartViewModel.Entry? {
        didSet {
            model.dataPointSelected?(selectedPoint)
        }
    }

    init(model: dydxLineChartViewModel, parentStyle: ThemeStyle = ThemeStyle.defaultStyle.themeFont(fontType: .number, fontSize: .large), styleKey: String?) {
        self.model = model
        self.parentStyle = parentStyle
        self.styleKey = styleKey
    }

    var body: some View {
        Chart {
            ForEach(model.entries, id: \.date) { entry in
                LineMark(x: .value("", entry.date),
                         y: .value("", entry.value))
                .lineStyle(StrokeStyle(lineWidth: 2))
                .foregroundStyle(model.lineColor.gradient)
                .interpolationMethod(.monotone)
                .symbolSize(0)

                // adds gradient shading
                AreaMark(
                    x: .value("", entry.date),
                    yStart: .value("", model.valuesDomain.lowerBound),
                    yEnd: .value("", entry.value)
                )
                .foregroundStyle(chartGradient)
            }

            if let selectedPoint {
                RuleMark(x: .value("Selected", selectedPoint.date))
                    .foregroundStyle(ThemeColor.SemanticColor.textTertiary.color.opacity(0.5))
                    .lineStyle(StrokeStyle(lineWidth: 2, dash: [5]))

                // Circle at the RuleMark
                PointMark(
                    x: .value("Selected X", selectedPoint.date),
                    y: .value("Selected Y", selectedPoint.value)
                )
                .symbol {
                    ZStack {
                        Circle()
                            .frame(width: 12, height: 12)
                            .foregroundStyle(model.backgroundColor.color)
                        Circle()
                            .frame(width: 8, height: 8)
                            .foregroundStyle(ThemeColor.SemanticColor.textSecondary.color)
                    }
                }
            }
        }
        .chartXAxis(.hidden)
        .chartYAxis {
            if model.showYLabels {
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
        .chartOverlay { proxy in
            GeometryReader { geo in
                Rectangle()
                    .fill(Color.clear)
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                guard model.dataPointSelected != nil else { return }

                                let relativeX = value.location.x - geo[proxy.plotAreaFrame].origin.x
                                if let xVal: Double = proxy.value(atX: relativeX) {
                                    // Nearest match in the dataset
                                    if let nearest = model.entries.min(by: { abs($0.date - xVal) < abs($1.date - xVal) }) {
                                        selectedPoint = nearest
                                    }
                                }
                            }
                            .onEnded { _ in
                                selectedPoint = nil
                            }
                    )
            }
        }
        .themeStyle(style: parentStyle)
        .environmentObject(themeSettings)
    }

    private var chartGradient: Gradient {
        Gradient(colors: [model.lineColor.opacity(0.3),
                          model.lineColor.opacity(0)])
    }
}
