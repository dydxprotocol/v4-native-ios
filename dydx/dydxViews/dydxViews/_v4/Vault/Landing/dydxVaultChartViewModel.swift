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

    @Published public var selectedValueType: ValueTypeOption = .pnl
    @Published public var selectedValueTime: ValueTimeOption = .sevenDays

    fileprivate let valueTypeOptions = ValueTypeOption.allCases
    fileprivate let valueTimeOptions = ValueTimeOption.allCases

    @Published public var chart = dydxLineChartViewModel()

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
        case sevenDays
        case thirtyDays
        case ninetyDays

        var displayText: String {
            let path: String
            switch self {
            case .sevenDays:
                path = "APP.GENERAL.TIME_STRINGS.7D"
            case .thirtyDays:
                path = "APP.GENERAL.TIME_STRINGS._30D"
            case .ninetyDays:
                path = "APP.GENERAL.TIME_STRINGS.90D"
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
        .frame(height: 38)
    }

    var body: some View {
        VStack(spacing: 8) {
            radioButtonsRow
            viewModel.chart.createView()
        }
    }
}
