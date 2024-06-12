//
//  dydxAdjustMarginAmountView.swift
//  dydxUI
//
//  Created by Rui Huang on 09/05/2024.
//  Copyright © 2024 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxAdjustMarginAmountViewModel: PlatformTextInputViewModel {
    @Published public var maxAction: (() -> Void)?

    public override var inputType: PlatformTextInputViewModel.InputType { .decimalDigits }

    public static var previewValue: dydxAdjustMarginAmountViewModel {
        let vm = dydxAdjustMarginAmountViewModel()
        vm.label = "Amount"
        vm.placeHolder = "0.0"
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        let superView = super.createView(parentStyle: parentStyle, styleKey: styleKey)
        return PlatformView { style in
            let view = HStack {
                superView

                let buttonContent = Text(DataLocalizer.localize(path: "APP.GENERAL.MAX"))
                    .themeFont(fontSize: .medium)
                    .wrappedViewModel

                PlatformButtonViewModel(content: buttonContent, type: .pill, state: .secondary, action: { [weak self] in

                    PlatformView.hideKeyboard()
                    self?.maxAction?()

                })
                .createView(parentStyle: style)
                .padding(.trailing, 8)
            }
                .makeInput()

            return AnyView(view)
        }
    }

}

#if DEBUG
struct dydxAdjustMarginAmountView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxAdjustMarginAmountViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxAdjustMarginAmountView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxAdjustMarginAmountViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
