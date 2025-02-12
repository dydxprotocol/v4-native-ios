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
    @Published public var marginUsage: Double?
    @Published public var learnMoreAction: (() -> Void)?

    public init() { }

    public static var previewValue: dydxSimpleUIMarginUsageViewModel {
        let vm = dydxSimpleUIMarginUsageViewModel()
        vm.marginUsage = 0.78
        return vm
    }

    private lazy var leverageTooltip: PlatformViewModel = {
        Tooltips.leverage(marginUsage: marginUsage) { [weak self] in
            self?.learnMoreAction?()
        }
    }()

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let view = HStack(alignment: .center, spacing: 8) {
                if let marginUsage = self.marginUsage {
                    self.leverageTooltip.createView(parentStyle: style)

                    let leveragePercent = LeverageRiskModel(marginUsage: marginUsage,
                                                            displayOption: .percent)
                    leveragePercent.createView(parentStyle: style.themeColor(foreground: .textTertiary))
                }
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
