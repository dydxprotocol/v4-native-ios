//
//  dydxTargetLeverageView.swift
//  dydxUI
//
//  Created by Rui Huang on 07/05/2024.
//  Copyright © 2024 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxTargetLeverageViewModel: PlatformViewModel {
    @Published public var description: String?

    public init() { }

    public static var previewValue: dydxTargetLeverageViewModel {
        let vm = dydxTargetLeverageViewModel()
        vm.description = "Test String"
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] _  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let view = VStack(alignment: .leading, spacing: 20) {
                Text(DataLocalizer.localize(path: "APP.TRADE.ADJUST_TARGET_LEVERAGE"))
                        .themeColor(foreground: .textPrimary)
                        .leftAligned()
                        .themeFont(fontType: .plus, fontSize: .largest)
                        .padding(.top, 40)

                Text(self.description ?? "")
                    .themeColor(foreground: .textTertiary)
                    .leftAligned()
                    .themeFont(fontSize: .medium)

                Spacer()
            }
                .padding(.horizontal)
                .themeColor(background: .layer3)
                .makeSheet(sheetStyle: .fitSize)

            // make it visible under the tabbar
            return AnyView(view.ignoresSafeArea(edges: [.bottom]))
        }
    }
}

#if DEBUG
struct dydxTargetLeverageView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxTargetLeverageViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxTargetLeverageView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxTargetLeverageViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
