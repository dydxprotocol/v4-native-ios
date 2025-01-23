//
//  dydxSimpleUITradeInputPositionView.swift
//  dydxUI
//
//  Created by Rui Huang on 23/01/2025.
//  Copyright © 2025 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxSimpleUITradeInputPositionViewModel: PlatformViewModel {
    @Published public var side: SideTextViewModel?
    @Published public var size: String?
    @Published public var token: String?
    public init() { }

    public static var previewValue: dydxSimpleUITradeInputPositionViewModel {
        let vm = dydxSimpleUITradeInputPositionViewModel()
        vm.side = .previewValue
        vm.size = "$100.00"
        vm.token = "ETH"
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let view = HStack {
                Text(DataLocalizer.localize(path: "APP.GENERAL.POSITION") + ":")
                    .themeColor(foreground: .textTertiary)

                HStack(spacing: 4) {
                    self.side?.createView(parentStyle: style.themeFont(fontSize: .small))

                    Text(self.size ?? "-")
                        .themeColor(foreground: .textPrimary)

                    Text(self.token ?? "-")
                        .themeColor(foreground: .textPrimary)
                }
            }
                .themeFont(fontSize: .small)

            return AnyView(view)
        }
    }
}

#if DEBUG
struct dydxSimpleUITradeInputPositionView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxSimpleUITradeInputPositionViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxSimpleUITradeInputPositionView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxSimpleUITradeInputPositionViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
