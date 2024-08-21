//
//  dydxTradeInputPostOnlyView.swift
//  dydxViews
//
//  Created by John Huang on 1/4/23.
//

import PlatformUI
import SwiftUI
import Utilities

public class dydxTradeInputPostOnlyViewModel: PlatformBooleanInputViewModel {
    public static var previewValue: dydxTradeInputPostOnlyViewModel = {
        let vm = dydxTradeInputPostOnlyViewModel(label: "Post Only", value: nil, onEdited: nil)
        return vm
    }()

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        let view = super.createView(parentStyle: parentStyle, styleKey: styleKey)
        return PlatformView { _ in
            AnyView(
                view
                    .padding(12)
            )
        }
    }
}

#if DEBUG
struct dydxTradeInputPostOnlyView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxTradeInputPostOnlyViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxTradeInputPostOnlyView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxTradeInputPostOnlyViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
