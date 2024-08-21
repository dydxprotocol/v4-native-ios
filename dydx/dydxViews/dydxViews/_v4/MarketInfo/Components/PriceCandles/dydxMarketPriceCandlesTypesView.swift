//
//  dydxMarketPriceCandlesTypesView.swift
//  dydxViews
//
//  Created by Rui Huang on 10/7/22.
//  Copyright © 2022 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxMarketPriceCandlesTypesViewModel: PlatformViewModel {
    @Published public var displayTypes: [String] = []
    @Published public var onDisplayTypeChanged: ((Int) -> Void)?
    @Published public var currentDisplayType: Int = 0

    public init() { }

    public init(displayTypes: [String] = [], onDisplayTypeChanged: ((Int) -> Void)? = nil, currentDisplayType: Int = 0) {
        self.displayTypes = displayTypes
        self.onDisplayTypeChanged = onDisplayTypeChanged
        self.currentDisplayType = currentDisplayType

        assert(currentDisplayType < displayTypes.count)
    }

    public static var previewValue: dydxMarketPriceCandlesTypesViewModel = {
        let vm = dydxMarketPriceCandlesTypesViewModel()
        vm.displayTypes = ["Candles", "Line"]
        return vm
    }()

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let items = self.displayTypes.compactMap {
                TabItemViewModel(value: .text($0), isSelected: false)
            }
            let selectedItems = self.displayTypes.compactMap {
                TabItemViewModel(value: .text($0), isSelected: true)
            }
            return AnyView(
                TabGroupModel(items: items,
                              selectedItems: selectedItems,
                              currentSelection: self.currentDisplayType,
                              onSelectionChanged: self.onDisplayTypeChanged)
                    .createView(parentStyle: style)
            )
        }
    }
}

#if DEBUG
struct dydxMarketInfoCandlesTypesViewModel_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxMarketPriceCandlesTypesViewModel.previewValue
            .createView()
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxMarketInfoCandlesTypesViewModel_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxMarketPriceCandlesTypesViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
