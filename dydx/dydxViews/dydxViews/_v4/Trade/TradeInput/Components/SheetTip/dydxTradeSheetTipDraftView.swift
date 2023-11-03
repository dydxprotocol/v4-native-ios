//
//  dydxTradeSheetTipDraftView.swift
//  dydxUI
//
//  Created by Rui Huang on 9/26/23.
//  Copyright © 2023 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxTradeSheetTipDraftViewModel: PlatformViewModel {
    @Published public var type: String?
    @Published public var side: SideTextViewModel?
    @Published public var size: SizeTextModel?
    @Published public var token: TokenTextViewModel?
    @Published public var price: AmountTextModel?

    public init() { }

    public static var previewValue: dydxTradeSheetTipDraftViewModel {
        let vm = dydxTradeSheetTipDraftViewModel()
        vm.type = "Market Order"
        vm.side = .previewValue
        vm.size = .previewValue
        vm.token = .previewValue
        vm.price = .previewValue
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            return AnyView(
                VStack(spacing: 6) {
                    HStack {
                        Text(DataLocalizer.localize(path: "APP.GENERAL.RETURN_TO_DRAFT"))
                            .themeColor(foreground: .textTertiary)
                            .themeFont(fontSize: .small)

                        Spacer()

                        self.size?
                            .createView(parentStyle: style
                                .themeColor(foreground: .textPrimary)
                                .themeFont(fontSize: .medium))

                        self.token?
                            .createView(parentStyle: style.themeFont(fontSize: .smallest))
                    }

                    HStack {
                        Text(self.type ?? "")
                            .themeColor(foreground: .textSecondary)
                            .themeFont(fontSize: .medium)

                        self.side?
                            .createView(parentStyle: style.themeFont(fontSize: .smallest))

                        Spacer()

                        self.price?
                            .createView(parentStyle: style
                                .themeColor(foreground: .textTertiary)
                                .themeFont(fontSize: .small))
                    }
                }
            )
        }
    }
}

#if DEBUG
struct dydxTradeSheetTipDraftView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxTradeSheetTipDraftViewModel.previewValue
            .createView()
            .environmentObject(themeSettings)
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxTradeSheetTipDraftView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxTradeSheetTipDraftViewModel.previewValue
            .createView()
            .environmentObject(themeSettings)
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
