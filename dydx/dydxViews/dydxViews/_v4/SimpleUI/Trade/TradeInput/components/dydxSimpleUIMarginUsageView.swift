//
//  dydxSimpleUIMarginUsageView.swift
//  dydxUI
//
//  Created by Rui Huang on 19/01/2025.
//  Copyright © 2025 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxSimpleUIMarginUsageViewModel: PlatformViewModel {
    @Published public var marginUsageTooltip = MarginUsageTooltipModel()
    @Published public var leveragePercent = LeverageRiskModel(marginUsage: 0, displayOption: .percent)

    public init() { }

    public static var previewValue: dydxSimpleUIMarginUsageViewModel {
        let vm = dydxSimpleUIMarginUsageViewModel()
        vm.marginUsageTooltip = .previewValue
        vm.leveragePercent = .previewValue
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let view = HStack(alignment: .center, spacing: 8) {
                self.marginUsageTooltip.createView(parentStyle: style)
                self.leveragePercent.createView(parentStyle: style.themeColor(foreground: .textTertiary))
            }
            return AnyView(view)
        }
    }
}

#if DEBUG
struct dydxSimpleUIMarginUsageView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxSimpleUIMarginUsageViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxSimpleUIMarginUsageView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxSimpleUIMarginUsageViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
