//
//  dydxNumberFieldView.swift
//  dydxViews
//
//  Created by Michael Maguire on 7/18/24.
//

import SwiftUI
import dydxFormatter
import PlatformUI
import Utilities

/// Effectively a TextField which forces its input as a number
/// Supports dydx-style title and title accesory view
struct dydxTitledNumberField: View {
    let title: String?
    let accessoryTitle: String?
    let numberFormatter: dydxNumberInputFormatter
    let minValue: Double
    let maxValue: Double
    let isMaxButtonVisible: Bool
    let withBorder: Bool
    @Binding var value: Double?
    @State private var textWidth: CGFloat = 0

    let minWidth: CGFloat = 100

    @ViewBuilder
    private var accessoryTitleView: some View {
        if let text = accessoryTitle {
            TokenTextViewModel(symbol: text)
                .createView(parentStyle: .defaultStyle.themeFont(fontType: .base, fontSize: .smallest))
        }
    }

    @ViewBuilder
    private var titleView: some View {
        if let text = title {
            Text(text)
                .themeColor(foreground: .textTertiary)
                .themeFont(fontType: .base, fontSize: .smaller)
                .background(
                    // this ensures that the text does not grow wider than the title or min width
                    GeometryReader { geometry in
                        Color.clear
                            .onAppear {
                                textWidth = max(geometry.size.width, minWidth)
                            }
                    }
                )
                .fixedSize()
        }
    }

    private var textFieldView: some View {
        NumberTextField(
            actualValue: $value,
            minValue: minValue,
            maxValue: maxValue,
            numberFormatter: numberFormatter)
        .themeColor(foreground: .textPrimary)
        .themeFont(fontType: .base, fontSize: .medium)
        .truncationMode(.middle)
        .frame(width: textWidth)
    }

    private var maxButton: some View {
        let buttonContent = Text(DataLocalizer.localize(path: "APP.GENERAL.MAX"))
            .themeFont(fontSize: .small)
            .wrappedViewModel

        return PlatformButtonViewModel(content: buttonContent, type: .pill, state: .secondary, action: {
            PlatformView.hideKeyboard()
            self.value = maxValue
        })
            .createView()

    }

    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 5) {
                    titleView
                    accessoryTitleView
                }
                textFieldView
            }

            if isMaxButtonVisible {
                Spacer()
                maxButton
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .makeInput(withBorder: withBorder)
    }
}

/// formats input as it is received
private struct NumberTextField: View {
    @Binding var actualValue: Double?
    @FocusState private var isFocused: Bool

    let minValue: Double
    let maxValue: Double
    let numberFormatter: dydxNumberInputFormatter

    private var keyboardType: UIKeyboardType {
        numberFormatter.fractionDigits > 0 ? .decimalPad : .numberPad
    }

    @ViewBuilder
    private var placeholder: some View {
        Text(numberFormatter.string(for: Double.zero) ?? "")
            .themeFont(fontType: .base, fontSize: .medium)
            .themeColor(foreground: .textTertiary)
    }

    var body: some View {
        TextField(text: filteredTextBinding) {
            placeholder
        }
        .keyboardType(keyboardType)
        .focused($isFocused)
        .onChange(of: isFocused) { _ in
            if !isFocused, let value =  Parser.standard.asInputDecimal(filteredTextBinding.wrappedValue)?.doubleValue {
                actualValue = formatValue(value)
            }
        }
    }

    private func formatValue(_ value: Double?) -> Double? {
        guard let value = value else {
            return nil
        }
        let multiplier = pow(10.0, Double(numberFormatter.fractionDigits))
        let formattedValue = (value * multiplier).rounded() / multiplier
        return formattedValue
    }

    private var filteredTextBinding: Binding<String> {
        Binding<String>(
            get: {
                if let value = actualValue {
                    return numberFormatter.string(from: NSNumber(value: value)) ?? ""
                } else {
                    return ""
                }
            },
            set: { newValue in
                if let doubleValue = Parser.standard.asInputDecimal(newValue)?.doubleValue {
                    actualValue = formatValue(clamp(doubleValue))
                } else {
                    actualValue = nil
                }
            }
        )
    }

    private func clamp(_ value: Double) -> Double {
        min(max(value, minValue), maxValue)
    }
}
