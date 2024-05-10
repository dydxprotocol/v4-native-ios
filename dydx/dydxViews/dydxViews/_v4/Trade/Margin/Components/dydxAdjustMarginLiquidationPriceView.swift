//
//  dydxAdjustMarginLiquidationPriceView.swift
//  dydxUI
//
//  Created by Rui Huang on 09/05/2024.
//  Copyright © 2024 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxAdjustMarginLiquidationPriceViewModel: PlatformViewModel {
    public enum Direction {
        case increase, decrease, none

        var gradientType: GradientType {
            switch self {
            case .increase:
                return .plus
            case .decrease:
                return .minus
            case .none:
                return .none
            }
        }
    }

    @Published public var direction = Direction.none
    @Published public var before: String?
    @Published public var after: String?

    public init() { }

    public static var previewValue: dydxAdjustMarginLiquidationPriceViewModel {
        let vm = dydxAdjustMarginLiquidationPriceViewModel()
        vm.direction = .increase
        vm.before = "$12,000.0"
        vm.before = "$12,300.0"
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] _  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            return AnyView(
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(DataLocalizer.localize(path: "APP.GENERAL.ESTIMATED"))
                            .themeColor(foreground: .textTertiary)
                            .themeFont(fontSize: .small)

                        Text(DataLocalizer.localize(path: "APP.TRADE.LIQUIDATION_PRICE"))
                            .themeColor(foreground: .textSecondary)
                            .themeFont(fontSize: .small)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 8) {
                        if self.after == nil {
                            Text(self.before ?? "")
                                .themeFont(fontSize: .large)
                                .themeColor(foreground: .textPrimary)
                        } else {
                            Text(self.before ?? "")
                                .themeFont(fontSize: .medium)
                                .themeColor(foreground: .textSecondary)

                            Text(self.after ?? "")
                                .themeFont(fontSize: .large)
                                .themeColor(foreground: .textPrimary)
                        }
                    }
                }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .themeGradient(background: .layer5, gradientType: self.direction.gradientType)
                    .cornerRadius(8)
                    .frame(height: 64)
            )
        }
    }
}

#if DEBUG
struct dydxAdjustMarginLiquidationPriceView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxAdjustMarginLiquidationPriceViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxAdjustMarginLiquidationPriceView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxAdjustMarginLiquidationPriceViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
