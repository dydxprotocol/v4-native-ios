//
//  dydxTitledTextField.swift
//  dydxViews
//
//  Created by Michael Maguire on 10/24/24.
//

import SwiftUI
import dydxFormatter
import PlatformUI
import Utilities

/// Effectively a TextField which forces its input as a number
/// Supports dydx-style title and title accesory view
struct dydxTitledTextField: View {
    let title: String
    let placeholder: String
    let isPasteEnabled: Bool
    let isClearEnabled: Bool
    @Binding var text: String

    private static let inputFontType: ThemeFont.FontType = .base
    private static let inputFontSize: ThemeFont.FontSize = .medium
    private static let inputFontHeight: CGFloat = {
        ThemeSettings.shared.themeConfig.themeFont.uiFont(of: inputFontType, fontSize: inputFontSize)?.lineHeight ?? 0
    }()

    init(title: String, placeholder: String, isPasteEnabled: Bool = false, isClearEnabled: Bool = true, text: Binding<String>) {
        self.title = title
        self.placeholder = placeholder
        self.isPasteEnabled = isPasteEnabled
        self.isClearEnabled = isClearEnabled
        self._text = text
    }

    @ViewBuilder
    private var titleView: some View {
        Text(title)
            .themeColor(foreground: .textTertiary)
            .themeFont(fontType: .base, fontSize: .smaller)
    }

    private var textFieldView: some View {
        TextField(text: $text) {
            placeholderView
        }
        .themeColor(foreground: .textPrimary)
        .themeFont(fontType: .base, fontSize: .medium)
        .truncationMode(.middle)
    }

    @ViewBuilder
    private var placeholderView: some View {
        Text(placeholder)
            .themeFont(fontType: .base, fontSize: .medium)
            .themeColor(foreground: .textTertiary)
    }

    private var clearButton: some View {
        let content = Image("icon_cancel", bundle: .dydxView)
            .resizable()
            .templateColor(.textSecondary)
            .padding(.all, 10)
            .frame(width: 32, height: 32)
            .borderAndClip(style: .circle, borderColor: .layer6)
            .wrappedViewModel

        return PlatformButtonViewModel(content: content,
                                       type: .iconType,
                                       state: .secondary) {
            self.text = ""
        }
                                       .createView()
    }

    private var pasteButton: some View {
        let buttonContent = Text(DataLocalizer.localize(path: "APP.GENERAL.PASTE"))
            .themeColor(foreground: .textSecondary)
            .themeFont(fontSize: .small)
            .wrappedViewModel

        return PlatformButtonViewModel(content: buttonContent,
                                type: .defaultType(fillWidth: false, padding: .init(horizontal: 8, vertical: 6)),
                                state: .secondary ) {
            self.text = UIPasteboard.general.string ?? ""
        }
            .createView()
            .frame(height: Self.inputFontHeight)
    }

    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 5) {
                titleView
                textFieldView
            }
            if isPasteEnabled && text.isEmpty {
                Spacer()
                pasteButton
            } else if isClearEnabled && !text.isEmpty {
                Spacer()
                clearButton
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .makeInput()
    }
}
