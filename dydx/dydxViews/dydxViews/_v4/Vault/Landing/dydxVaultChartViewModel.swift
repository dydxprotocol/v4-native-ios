//
//  dydxVaultChartViewModel.swift
//  dydxViews
//
//  Created by Michael Maguire on 8/2/24.
//

import Foundation
import PlatformUI
import SwiftUI
import Utilities
import Charts
import Combine
import dydxChart
import dydxFormatter

public class dydxVaultChartViewModel: PlatformViewModel {
    public struct Entry {
        let date: Double
        let value: Double

        public init(date: Double, value: Double) {
            self.date = date
            self.value = value
        }
    }

    @Published public var selectedValueType: ValueTypeOption = .pnl
    @Published public var selectedValueTime: ValueTimeOption = .sevenDays

    fileprivate let valueTypeOptions = ValueTypeOption.allCases
    fileprivate let valueTimeOptions = ValueTimeOption.allCases

    @Published public var entries: [Entry] = []
    fileprivate var isPositive: Bool { (entries.last?.value ?? -Double.infinity) >= (entries.first?.value ?? -Double.infinity) }
    fileprivate var lineColor: Color { isPositive ? ThemeSettings.positiveColor.color : ThemeSettings.negativeColor.color }
    fileprivate var datesDomain: ClosedRange<Double> { (entries.map(\.date).min() ?? 0)...(entries.map(\.date).max() ?? 0) }
    fileprivate var valuesDomain: ClosedRange<Double> { (entries.map(\.value).min() ?? 0)...(entries.map(\.value).max() ?? 0) }

    public enum ValueTypeOption: CaseIterable, RadioButtonContentDisplayable {
        case pnl
        case equity

        var displayText: String {
            let path: String
            switch self {
            case .pnl:
                path = "APP.VAULTS.VAULT_PNL"
            case .equity:
                path = "APP.VAULTS.VAULT_EQUITY"
            }
            return DataLocalizer.shared?.localize(path: path, params: nil) ?? ""
        }
    }

    public enum ValueTimeOption: CaseIterable, RadioButtonContentDisplayable {
        case oneDay
        case sevenDays
        case thirtyDays

        var displayText: String {
            let path: String
            switch self {
            case .oneDay:
                path = "APP.GENERAL.TIME_STRINGS.1D"
            case .sevenDays:
                path = "APP.GENERAL.TIME_STRINGS.7D"
            case .thirtyDays:
                path = "APP.GENERAL.TIME_STRINGS._30D"
            }
            return DataLocalizer.shared?.localize(path: path, params: nil) ?? ""
        }
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] _  in
            guard let self = self else { return AnyView(PlatformView.nilView) }
            return AnyView(dydxVaultChartView(viewModel: self)).wrappedInAnyView()
        }
    }
}

private struct dydxVaultChartView: View {
    @State private var selectedIndex: Int?
    @ObservedObject var viewModel: dydxVaultChartViewModel

    private var chartGradient: Gradient {
        Gradient(colors: [viewModel.lineColor.opacity(0.25),
                          viewModel.lineColor.opacity(0)])
    }

    private var radioButtonsRow: some View {
        GeometryReader { geometry in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    RadioButtonGroup(selected: $viewModel.selectedValueType,
                                     options: viewModel.valueTypeOptions,
                                     fontType: .base,
                                     fontSize: .smaller,
                                     itemWidth: nil,
                                     itemHeight: 32
                    )
                    Spacer(minLength: 32).layoutPriority(1)
                    RadioButtonGroup(selected: $viewModel.selectedValueTime,
                                     options: viewModel.valueTimeOptions,
                                     fontType: .base,
                                     fontSize: .smaller,
                                     itemWidth: nil,
                                     itemHeight: 32
                    )
                }
                .padding(.horizontal, 12)
                .frame(minWidth: geometry.size.width, alignment: .center)
            }
        }
        .frame(height: 32)
    }
//        .chartOverlay { chart in
//            GeometryReader { geometry in
//                Rectangle()
//                    .fill(Color.clear)
//                    .contentShape(Rectangle())
//                    .gesture(
//                        DragGesture()
//                            .onChanged { value in
//                                let currentX = value.location.x - geometry[chart.plotAreaFrame].origin.x
//                                guard currentX >= 0, currentX < chart.plotAreaSize.width else {
//                                    return
//                                }
//
//                                guard let index = chart.value(atX: currentX, as: Int.self) else {
//                                    return
//                                }
//                                selectedIndex = index
//                            }
//                            .onEnded { _ in
//                                selectedIndex = nil
//                            }
//                    )
//            }
//        }
    private var chart: some View {
        let fontSize = ThemeFont.FontSize.smaller
        let fontType = ThemeFont.FontType.base
        let fontLineHeight = ThemeSettings.shared.themeConfig.themeFont.uiFont(of: fontType, fontSize: fontSize)?.lineHeight ?? 0
        let data = Array(zip(viewModel.entries, viewModel.entries.indices))
        // overlay the charts so that y axis markers can be overlayed behind the chart
        return ZStack {
            Chart(data, id: \.0.date) { entry, _ in
                LineMark(x: .value("", entry.date),
                         y: .value("", entry.value))
                .foregroundStyle(.clear)
            }
            .chartYAxis {
                AxisMarks {
                    AxisValueLabel(format: CondensedDollar())
                        .themeFont(fontType: fontType, fontSize: fontSize)
                        .themeColor(foreground: .textTertiary)
                    AxisGridLine()
                        .foregroundStyle(ThemeColor.SemanticColor.textTertiary.color.opacity(0.2))
                }
            }

            Chart(data, id: \.0.date) { entry, _ in
                LineMark(x: .value("", entry.date),
                         y: .value("", entry.value))
                .lineStyle(StrokeStyle(lineWidth: 2))
                .foregroundStyle(viewModel.lineColor.gradient)
                .interpolationMethod(.linear)
                .symbolSize(0)
                // adds gradient shading
                AreaMark(
                    x: .value("", entry.date),
                    yStart: .value("", viewModel.valuesDomain.lowerBound),
                    yEnd: .value("", entry.value)
                )
                .foregroundStyle(chartGradient)
            }
            .chartYAxis(.hidden)
        }
        .chartXAxis(.hidden)
        .chartXScale(domain: .automatic(includesZero: false))
        .chartYScale(domain: .automatic(includesZero: false))
        // the y axis labels can extend outside of chart
        .padding(.vertical, fontLineHeight / 2)
    }

    var body: some View {
        VStack(spacing: 16) {
            radioButtonsRow
            chart
        }
    }
}

private struct CondensedDollar: FormatStyle {
    func format(_ value: Double) -> String {
        dydxFormatter.shared.condensed(number: value, digits: 2) ?? ""
    }
}
