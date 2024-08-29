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
    @Published public var selectedValueType: ValueTypeOption = .pnl
    @Published public var selectedValueTime: ValueTimeOption = .oneDay

    fileprivate let valueTypeOptions = ValueTypeOption.allCases
    fileprivate let valueTimeOptions = ValueTimeOption.allCases

    fileprivate let lineChart = {
        let lineChart = LineChartView()
        lineChart.data = LineChartData()
        lineChart.xAxis.drawGridLinesEnabled = false
        lineChart.leftAxis.enabled = false
        lineChart.rightAxis.enabled = false
        lineChart.xAxis.drawGridLinesEnabled = false
        lineChart.xAxis.drawAxisLineEnabled = false
        lineChart.xAxis.labelPosition = .bottom
        lineChart.xAxis.setLabelCount(5, force: true)
        lineChart.xAxis.granularityEnabled = true
        lineChart.xAxis.labelTextColor = ThemeColor.SemanticColor.textTertiary.uiColor
        lineChart.xAxis.labelFont = ThemeSettings.shared.themeConfig.themeFont.uiFont(of: .number, fontSize: .smallest) ?? .systemFont(ofSize: 11)
        lineChart.xAxis.valueFormatter = ValueTimeOption.oneDay.valueFormatter
        lineChart.xAxis.avoidFirstLastClippingEnabled = true
        // default is 5, but then would have to add that offset to ViewPortOffsets's bottom
        lineChart.xAxis.yOffset = 0
        // enables edge-to-edge
        lineChart.setViewPortOffsets(left: 0, top: 0, right: 0, bottom: lineChart.xAxis.labelFont.lineHeight * 2)
        lineChart.pinchZoomEnabled = false
        lineChart.doubleTapToZoomEnabled = false
        // enables dragging the highlighted value indicator
        lineChart.dragEnabled = true
        lineChart.legend.enabled = false

        return lineChart
    }()

    public init() {}

    // TODO: replace with actual data
    public func setEntries(entries: [ChartDataEntry] = []) {
        let dataSet = LineChartDataSet(entries: entries)
        let isPositive = (entries.last?.y ?? -Double.infinity) >= (entries.first?.y ?? -Double.infinity)
        let color = isPositive ? ThemeSettings.positiveColor.uiColor : ThemeSettings.negativeColor.uiColor
        let gradientColors = [
            color.withAlphaComponent(0).cgColor,
            color.withAlphaComponent(1).cgColor]
        let gradient = CGGradient(colorsSpace: nil, colors: gradientColors as CFArray, locations: nil)!

        // colors
        dataSet.fill = .fillWithLinearGradient(gradient, angle: 90)
        dataSet.highlightColor = color
        dataSet.setColor(color)
        dataSet.drawFilledEnabled = true

        // shapes
        dataSet.lineWidth = 3
        dataSet.lineCapType = .round
        dataSet.mode = .linear
        dataSet.label = nil
        dataSet.drawCirclesEnabled = false
        dataSet.drawValuesEnabled = false

        // interactions
        dataSet.highlightEnabled = true
        dataSet.drawHorizontalHighlightIndicatorEnabled = false

        lineChart.xAxis.valueFormatter = selectedValueTime.valueFormatter

        lineChart.data = LineChartData(dataSet: dataSet)
    }

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

        fileprivate var valueFormatter: TimeAxisValueFormatter {
            let formatter = TimeAxisValueFormatter()
            switch self {
            case .oneDay:
                formatter.dateFormat = "HH:mm"
            case .sevenDays, .thirtyDays:
                formatter.dateFormat = "HH:mm\nMM/dd"
            }
            return formatter
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

    private var radioButtonsRow: some View {
        HStack(spacing: 0) {
            RadioButtonGroup(selected: $viewModel.selectedValueType,
                             options: viewModel.valueTypeOptions,
                             buttonClipStyle: .capsule,
                             itemWidth: nil,
                             itemHeight: 40
            )
            Spacer()
            RadioButtonGroup(selected: $viewModel.selectedValueTime,
                             options: viewModel.valueTimeOptions,
                             buttonClipStyle: .circle,
                             itemWidth: 40,
                             itemHeight: 40
            )
        }
        .padding(.horizontal, 12)
    }

    private var chart: some View {
        viewModel.lineChart.swiftUIView
    }

    var body: some View {
        VStack(spacing: 12) {
            radioButtonsRow
            chart
        }
    }
}

// DateTimeAxisFormatter is broken for ONEHOUR and seem to overcomplicate time value formatting so writing custom IAxisValueFormatter
private class TimeAxisValueFormatter: DateFormatter, IAxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let date = Date(timeIntervalSince1970: value)
        return self.string(from: date)
    }
}
