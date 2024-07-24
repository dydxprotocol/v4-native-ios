//
//  dydxNumberFieldView.swift
//  dydxViews
//
//  Created by Michael Maguire on 7/18/24.
//

import SwiftUI
import dydxFormatter
import PlatformUI

/// Effectively a TextField which forces its input as a number
struct dydxTitledNumberField: View {
    let title: String?
    let accessoryTitle: String?
    let placeholder: String?
    let precision: Int
    let minValue: Double
    let maxValue: Double
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
            precision: precision)
        .themeColor(foreground: .textPrimary)
        .themeFont(fontType: .base, fontSize: .medium)
        .truncationMode(.middle)
        .frame(width: textWidth)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack(spacing: 5) {
                titleView
                accessoryTitleView
            }
            textFieldView
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .makeInput()
    }
}

/// formats input as it is received
private struct NumberTextField: View {
    @Binding var actualValue: Double?
    @FocusState private var isFocused: Bool

    let minValue: Double
    let maxValue: Double
    let precision: Int

    private var numberFormatter: dydxNumberInputFormatter {
        dydxNumberInputFormatter(fractionDigits: precision)
    }

    private var keyboardType: UIKeyboardType {
        precision > 0 ? .decimalPad : .numberPad
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
            if !isFocused, let value = Double(filteredTextBinding.wrappedValue) {
                actualValue = formatValue(value)
            }
        }
        .keyboardAccessory(parentStyle: .defaultStyle)
    }

    private func formatValue(_ value: Double?) -> Double? {
        guard let value = value else {
            return nil
        }
        let multiplier = pow(10.0, Double(precision))
        let formattedValue = (value * multiplier).rounded() / multiplier
        return formattedValue
    }

    private var filteredTextBinding: Binding<String> {
        Binding<String>(
            get: {
                if let value = actualValue {
                    print("mmm: numberFormatter.string(from: NSNumber(value: value)): \(numberFormatter.string(from: NSNumber(value: value)))")
                    return numberFormatter.string(from: NSNumber(value: value)) ?? ""
                } else {
                    return ""
                }
            },
            set: { newValue in
                if let doubleValue = Double(newValue) {
                    print("mmm: formatValue(clamp(doubleValue): \(formatValue(clamp(doubleValue)))")
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

    private func formatNumber(_ value: Double) -> Double {
        let multiplier = pow(10.0, Double(precision))
        let formattedValue = (value * multiplier).rounded() / multiplier
        return formattedValue
    }
}
