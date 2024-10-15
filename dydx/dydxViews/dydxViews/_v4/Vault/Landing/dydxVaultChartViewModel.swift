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
    @Published public var selectedValueTime: ValueTimeOption = .thirtyDays

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
    @ObservedObject var viewModel: dydxVaultChartViewModel

    private var chartGradient: Gradient {
        Gradient(colors: [viewModel.lineColor.opacity(0.25),
                          viewModel.lineColor.opacity(0)])
    }

    private var radioButtonsRow: some View {
        HStack(spacing: 0) {
            RadioButtonGroup(selected: $viewModel.selectedValueType,
                             options: viewModel.valueTypeOptions,
                             fontType: .base,
                             fontSize: .smaller,
                             itemWidth: nil,
                             itemHeight: 32
            )
            Spacer().layoutPriority(1)
            RadioButtonGroup(selected: $viewModel.selectedValueTime,
                             options: viewModel.valueTimeOptions,
                             fontType: .base,
                             fontSize: .smaller,
                             itemWidth: nil,
                             itemHeight: 32
            )
        }
        .padding(.horizontal, 12)
    }

    private var chart: some View {
        Chart(viewModel.entries, id: \.date) { entry in
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
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
        .chartXScale(domain: .automatic(includesZero: false))
        .chartYScale(domain: .automatic(includesZero: false))

        // the lines can extend outside of chart
        .padding(.all, 1)
    }

    var body: some View {
        VStack(spacing: 12) {
            radioButtonsRow
            chart
        }
    }
}
