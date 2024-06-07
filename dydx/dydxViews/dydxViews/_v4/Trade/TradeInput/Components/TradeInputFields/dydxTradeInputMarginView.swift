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
    @Published public var shouldDisplayTargetLeverage: Bool = false
    @Published public var marginMode: String?
    @Published public var targetLeverage: String?
    @Published public var marginModeAction: (() -> Void)?
    @Published public var marginLeverageAction: (() -> Void)?

    private let borderRadius: CGFloat = 12
    private let optionHeight: CGFloat = 44

    public init() { }

    public static var previewValue: dydxTradeInputMarginViewModel {
        let vm = dydxTradeInputMarginViewModel()
        vm.targetLeverage = "2×"
        return vm
    }

    private var marginModeView: some View {
        let content = HStack(spacing: 0) {
            Spacer()
            HStack(spacing: 4) {
                Text(self.marginMode ?? "")
                    .themeFont(fontSize: .medium)
                    .themeColor(foreground: .textPrimary)
                Text("⏵")
                    .themeFont(fontSize: .smaller)
                    .themeColor(foreground: .textTertiary)
            }
            Spacer()
        }
            .wrappedViewModel

        return PlatformButtonViewModel(
            content: content,
            type: .iconType,
            state: .secondary) { [weak self] in
            self?.marginModeAction?()
        }
        .createView()
    }

    private var targetLeverageView: PlatformView? {
        guard shouldDisplayTargetLeverage else { return nil }
        let content = HStack(spacing: 2) {
            Text(self.targetLeverage ?? "")
                .themeFont(fontSize: .medium)
                .themeColor(foreground: .textPrimary)
            Text("×")
                .themeFont(fontType: .plus, fontSize: .smaller)
                .themeColor(foreground: .textTertiary)
        }
            .padding(.horizontal, 16)
            .wrappedViewModel

        return PlatformButtonViewModel(
            content: content,
            type: .iconType,
            state: .secondary
        ) { [weak self] in
            self?.marginLeverageAction?()
        }
        .createView()
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] _  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            return AnyView(
                HStack(spacing: 8) {
                    Group {
                        self.marginModeView
                        self.targetLeverageView
                    }
                    .frame(height: self.optionHeight)
                    .themeColor(background: .layer5)
                    .borderAndClip(style: .cornerRadius(self.borderRadius), borderColor: .layer7)
                }
            )
        }
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
