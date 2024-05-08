//
//  dydxTradeInputMarginView.swift
//  dydxUI
//
//  Created by Rui Huang on 07/05/2024.
//  Copyright © 2024 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxTradeInputMarginViewModel: PlatformViewModel {
    @Published public var marginMode: String?
    @Published public var marginLeverage: String?
    @Published public var marginModeAction: (() -> Void)?
    @Published public var marginLeverageAction: (() -> Void)?

    public init() { }

    public static var previewValue: dydxTradeInputMarginViewModel {
        let vm = dydxTradeInputMarginViewModel()
        vm.marginLeverage = "2x"
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            return AnyView(
                HStack(spacing: 8) {
                    let marginModeText =
                        self.createButtonContent(parentStyle: style,
                                                 text: self.marginMode ?? "")
                            .wrappedViewModel
                    PlatformButtonViewModel(content: marginModeText,
                                            type: PlatformButtonType.iconType) { [weak self] in
                        self?.marginModeAction?()
                    }
                    .createView(parentStyle: style)

                    let marginLeverageText =
                        self.createButtonContent(parentStyle: style,
                                                 text: self.marginLeverage ?? "")
                        .wrappedViewModel
                    PlatformButtonViewModel(content: marginLeverageText,
                                            type: PlatformButtonType.iconType) { [weak self] in
                        self?.marginLeverageAction?()
                    }
                    .createView(parentStyle: style)
                    .frame(width: 60)
                }
            )
        }
    }

    private let optionHeight: CGFloat = 44
    private let cornerRadius: CGFloat = 12
    private let optionPadding: CGFloat = 3

    private func createButtonContent(parentStyle: ThemeStyle, text: String) -> some View {
        Text(text)
            .themeFont(fontSize: .medium)
            .themeColor(foreground: .textPrimary)
            .frame(height: optionHeight)
            .frame(minWidth: 0, maxWidth: .infinity)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .strokeBorder(ThemeColor.SemanticColor.textTertiary.color, lineWidth: 1)
            )
            .contentShape(RoundedRectangle(cornerRadius: cornerRadius))
            .padding(optionPadding)
    }
}

#if DEBUG
struct dydxTradeInputMarginView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxTradeInputMarginViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxTradeInputMarginView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxTradeInputMarginViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
