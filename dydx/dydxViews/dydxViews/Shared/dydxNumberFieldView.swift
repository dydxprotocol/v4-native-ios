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
struct dydxNumberField: View {
    let title: String?
    let accessoryTitle: String?
    let placeholder: String?
    let formatter: dydxNumberInputFormatter
    @Binding var value: Double
    @State private var textWidth: CGFloat = 0

    let minWidth: CGFloat = 100

    private var keyboardType: UIKeyboardType {
        formatter.fractionDigits > 0 ? .decimalPad : .numberPad
    }

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
        return TextField(
            "",
            value: $value,
            formatter: formatter
        )
        .themeColor(foreground: .textPrimary)
        .themeFont(fontType: .base, fontSize: .medium)
        .keyboardType(keyboardType)
        .keyboardAccessory(parentStyle: .defaultStyle)
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
