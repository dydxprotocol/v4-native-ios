//
//  dydxSimpleUIBuyingPowerView.swift
//  dydxUI
//
//  Created by Rui Huang on 16/01/2025.
//  Copyright © 2025 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxSimpleUIBuyingPowerViewModel: PlatformViewModel {
    public struct BuyingPowerChange: Identifiable {
        let symbol: String
        let change: AmountChangeModel

        public var id: String {
            symbol
        }

        public init(symbol: String, change: AmountChangeModel) {
            self.symbol = symbol
            self.change = change
        }
    }

    @Published public var buyingPowerChange: BuyingPowerChange?

    public init() {}

    public static var previewValue: dydxSimpleUIBuyingPowerViewModel = {
        let vm = dydxSimpleUIBuyingPowerViewModel()
        vm.buyingPowerChange = BuyingPowerChange(symbol: "", change: .previewValue)
        return vm
    }()

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            return AnyView(
                HStack {
                    Text(DataLocalizer.localize(path: "APP.GENERAL.BUYING_POWER") + ":")
                        .themeFont(fontSize: .small)
                        .themeColor(foreground: .textTertiary)
                        .lineLimit(1)

                    if let buyingPowerChange = self.buyingPowerChange?.change {
                        buyingPowerChange.createView(parentStyle: style)
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
struct dydxSimpleUIBuyingPowerView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxSimpleUIBuyingPowerViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxSimpleUIBuyingPowerView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxSimpleUIBuyingPowerViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
