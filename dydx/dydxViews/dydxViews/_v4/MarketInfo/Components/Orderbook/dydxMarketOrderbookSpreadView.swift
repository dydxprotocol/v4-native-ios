//
//  dydxMarketOrderbookSpreadView.swift
//  dydxUI
//
//  Created by Rui Huang on 5/25/23.
//  Copyright © 2023 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities
import dydxFormatter

public class dydxMarketOrderbookSpreadViewModel: dydxOrderbookSpreadViewModel {
    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] _  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let text = dydxFormatter.shared.percent(number: self.percent, digits: 2) ?? ""
            return AnyView(
                HStack {
                    Text(DataLocalizer.localize(path: "APP.TRADE.ORDERBOOK_SPREAD"))
                        .themeColor(foreground: .textTertiary)
                        .themeFont(fontType: .text, fontSize: .small)

                    Text(text)
                        .themeColor(foreground: .textPrimary)
                        .themeFont(fontType: .number, fontSize: .small)
                }
            )
        }
    }
}

#if DEBUG
struct dydxMarketOrderbookSpreadView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxMarketOrderbookSpreadViewModel.previewValue
            .createView()
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxMarketOrderbookSpreadView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxMarketOrderbookSpreadViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
