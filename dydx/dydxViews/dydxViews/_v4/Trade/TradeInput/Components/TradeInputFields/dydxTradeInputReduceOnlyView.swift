//
//  dydxTradeInputReduceOnlyView.swift
//  dydxViews
//
//  Created by John Huang on 1/4/23.
//

import PlatformUI
import SwiftUI
import Utilities

public class dydxTradeInputReduceOnlyViewModel: PlatformBooleanInputViewModel {
    public static var previewValue: dydxTradeInputReduceOnlyViewModel = {
        let vm = dydxTradeInputReduceOnlyViewModel(label: "Reduce Only", value: nil, onEdited: nil)
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
struct dydxTradeInputReduceOnlyView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxTradeInputReduceOnlyViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxTradeInputReduceOnlyView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxTradeInputReduceOnlyViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
