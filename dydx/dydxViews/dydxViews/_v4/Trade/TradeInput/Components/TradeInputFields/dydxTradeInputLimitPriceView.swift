//
//  dydxTradeInputLimitPriceView.swift
//  dydxViews
//
//  Created by John Huang on 1/4/23.
//

import PlatformUI
import SwiftUI
import Utilities

public class dydxTradeInputLimitPriceViewModel: PlatformTextInputViewModel {
    public static var previewValue: dydxTradeInputLimitPriceViewModel = {
        let vm = dydxTradeInputLimitPriceViewModel(label: "Limit Price", value: "100.0", placeHolder: "0.000")
        return vm
    }()

    public init(label: String? = nil, value: String? = nil, placeHolder: String? = nil, contentType: UITextContentType? = nil, onEdited: ((String?) -> Void)? = nil) {
        super.init(label: label, value: value, placeHolder: placeHolder, inputType: .decimalDigits, contentType: contentType, onEdited: onEdited)
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        let view = super.createView(parentStyle: parentStyle, styleKey: styleKey)
        return PlatformView { _ in
            AnyView(view.makeInput())
        }
    }

    public override var header: PlatformViewModel {
        HStack(spacing: 2) {
            Text(label ?? "")
                .themeColor(foreground: .textTertiary)
            Text("USD")
        }
        .themeFont(fontSize: .smaller)
        .wrappedViewModel
    }
}

#if DEBUG
struct dydxTradeInputLimitPriceView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxTradeInputLimitPriceViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxTradeInputLimitPriceView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxTradeInputLimitPriceViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
