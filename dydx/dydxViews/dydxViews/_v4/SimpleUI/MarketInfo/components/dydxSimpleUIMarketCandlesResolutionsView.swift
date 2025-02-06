//
//  dydxSimpleUIMarketCandlesResolutionsView.swift
//  dydxUI
//
//  Created by Rui Huang on 26/12/2024.
//  Copyright © 2024 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxSimpleUIMarketCandlesResolutionsViewModel: PlatformViewModel {
    @Published public var resolutions: [String] = []
    @Published public var onResolutionChanged: ((Int) -> Void)?
    @Published public var currentResolution: Int = 0

    public init() { }

    public init(resolutions: [String] = [], onResolutionChanged: ((Int) -> Void)? = nil, currentResolution: Int = 0) {
        self.resolutions = resolutions
        self.onResolutionChanged = onResolutionChanged
        self.currentResolution = currentResolution
    }

    public static var previewValue: dydxSimpleUIMarketCandlesResolutionsViewModel {
        let vm = dydxSimpleUIMarketCandlesResolutionsViewModel()
        vm.resolutions = ["1m", "5m", "15m", "30m", "1h", "2h"]
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let items = self.resolutions.compactMap {
                Text($0)
                    .themeColor(foreground: .textTertiary)
                    .themeFont(fontSize: .small)
                    .wrappedViewModel
            }
            let selectedItems = self.resolutions.compactMap {
                Text($0)
                    .themeColor(foreground: .textPrimary)
                    .themeFont(fontSize: .small)
                    .wrappedViewModel
            }
            return AnyView(
                GeometryReader { proxy in
                    ScrollView(.horizontal) {
                        HStack {
                            TabGroupModel(items: items,
                                          selectedItems: selectedItems,
                                          currentSelection: self.currentResolution,
                                          onSelectionChanged: self.onResolutionChanged,
                                          spacing: 24,
                                          layoutConfig: .naturalSize)
                            .createView(parentStyle: style)
                            .padding(.horizontal, 16)
                        }
                        .frame(minWidth: proxy.size.width)
                    }
                    .frame(height: 32)
                }
            )
        }
    }
}

#if DEBUG
struct dydxSimpleUIMarketCandlesResolutionsView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxSimpleUIMarketCandlesResolutionsViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxSimpleUIMarketCandlesResolutionsView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxSimpleUIMarketCandlesResolutionsViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
