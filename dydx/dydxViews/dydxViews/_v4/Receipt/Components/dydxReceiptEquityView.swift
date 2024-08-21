//
//  dydxReceiptEquityView.swift
//  dydxUI
//
//  Created by Rui Huang on 8/26/23.
//  Copyright © 2023 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxReceiptEquityViewModel: PlatformViewModel {
    @Published public var equityChange: AmountChangeModel?
    @Published public var usdcTokenName: String?

    public init() { }

    public static var previewValue: dydxReceiptEquityViewModel {
        let vm = dydxReceiptEquityViewModel()
        vm.equityChange = .previewValue
        vm.usdcTokenName = "USDC"
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            return AnyView(
                HStack(spacing: 4) {
                    Text(DataLocalizer.localize(path: "APP.GENERAL.EQUITY"))
                        .themeFont(fontSize: .small)
                        .themeColor(foreground: .textTertiary)
                        .lineLimit(1)
                    TokenTextViewModel(symbol: self.usdcTokenName ?? "")
                        .createView(parentStyle: style.themeFont(fontSize: .smallest))
                        .lineLimit(1)

                    Spacer()
                    if let equityChange = self.equityChange {
                        equityChange.createView(parentStyle: style)
                            .lineLimit(1)
                    } else {
                        dydxReceiptEmptyView.emptyValue
                    }
                }
            )
        }
    }
}

#if DEBUG
struct dydxReceiptEquityView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxReceiptEquityViewModel.previewValue
            .createView()
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxReceiptEquityView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxReceiptEquityViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
