//
//  dydxOrderTranslationView.swift
//  dydxUI
//
//  Created by Michael Maguire on 1/18/24.
//  Copyright © 2024 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxOrderTranslationViewModel: PlatformViewModel {
    @Published public var text: AttributedString?

    public init() { }

    public static var previewValue: dydxOrderTranslationViewModel {
        let vm = dydxOrderTranslationViewModel()
        vm.text = "Test String"
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] _  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            return Text(self.text ?? "")
                        .themeFont(fontType: .text, fontSize: .small)
                        .multilineTextAlignment(.leading)
                        .wrappedInAnyView()
        }
    }
}

// #if DEBUG
#Preview("dydxOrderTranslationView_Previews_Dark") {
    @StateObject var themeSettings = ThemeSettings.shared

    ThemeSettings.applyDarkTheme()
    ThemeSettings.applyStyles()
    return dydxOrderTranslationViewModel.previewValue
        .createView()
        // .edgesIgnoringSafeArea(.bottom)
        .previewLayout(.sizeThatFits)
}

#Preview("dydxOrderTranslationView_Previews_Light") {
    @StateObject var themeSettings = ThemeSettings.shared

    ThemeSettings.applyLightTheme()
    ThemeSettings.applyStyles()
    return dydxOrderTranslationViewModel.previewValue
        .createView()
    // .edgesIgnoringSafeArea(.bottom)
        .previewLayout(.sizeThatFits)
}
// #endif
