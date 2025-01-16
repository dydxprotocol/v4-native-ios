//
//  dydxSimpleUIMarketBuySellView.swift
//  dydxUI
//
//  Created by Rui Huang on 16/01/2025.
//  Copyright © 2025 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxSimpleUIMarketBuySellViewModel: PlatformViewModel {
    @Published public var text: String?
    @Published public var buyAction: (() -> Void)?
    @Published public var sellAction: (() -> Void)?

    public init() { }

    public static var previewValue: dydxSimpleUIMarketBuySellViewModel {
        let vm = dydxSimpleUIMarketBuySellViewModel()
        vm.text = "Test String"
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] _  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let view = HStack(spacing: 16) {
                Button {
                    self.buyAction?()
                } label: {
                    Text(DataLocalizer.localize(path: "APP.GENERAL.SELL"))
                        .themeColor(foreground: .colorRed)
                }
                .frame(height: 56)
                .frame(maxWidth: .infinity)
                .background(ThemeColor.SemanticColor.colorRed.color.opacity(0.2))
                .cornerRadius(8, corners: .allCorners)

                Button {
                    self.buyAction?()
                } label: {
                    Text(DataLocalizer.localize(path: "APP.GENERAL.BUY"))
                        .themeColor(foreground: .colorGreen)
                }
                .frame(height: 56)
                .frame(maxWidth: .infinity)
                .background(ThemeColor.SemanticColor.colorGreen.color.opacity(0.2))
                .cornerRadius(8, corners: .allCorners)
            }
                .padding(.horizontal, 16)

            return AnyView(view)
        }
    }
}

#if DEBUG
struct dydxSimpleUIMarketBuySellView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxSimpleUIMarketBuySellViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxSimpleUIMarketBuySellView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxSimpleUIMarketBuySellViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
