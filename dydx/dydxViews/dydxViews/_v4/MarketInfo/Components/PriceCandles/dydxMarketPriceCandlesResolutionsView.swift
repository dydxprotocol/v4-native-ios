//
//  dydxMarketPriceCandlesResolutionssView.swift
//  dydxViews
//
//  Created by Rui Huang on 10/7/22.
//  Copyright © 2022 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxMarketPriceCandlesResolutionsViewModel: PlatformPopoverOptionsInputViewModel {

    public init() {
        super.init()
        position = .absolute(originAnchor: .bottom, popoverAnchor: .top)
    }

    public static var previewValue: dydxMarketPriceCandlesResolutionsViewModel = {
        let vm = dydxMarketPriceCandlesResolutionsViewModel()
        vm.options = [
            InputSelectOption(value: "1h", string: "1h"),
            InputSelectOption(value: "1m", string: "1m")
        ]
        return vm
    }()

    public override var selectedItemView: PlatformViewModel {
        let selectedOption = options?.first { option in
            option.value == self.value
        }
        if let selectedOption = selectedOption {
            let text = selectedOption.string
            return TabGroupModel(items: [TabItemViewModel(value: .text(text), isSelected: false)],
                                 selectedItems: [TabItemViewModel(value: .text(text), isSelected: false)],
                                 currentSelection: 0,
                                 onSelectionChanged: {_ in })
        }
        return PlatformView.nilViewModel
    }
}

#if DEBUG
struct dydxMarketInfoCandlesResolutionssViewModel_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxMarketPriceCandlesResolutionsViewModel.previewValue
            .createView()
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxMarketInfoCandlesResolutionssViewModel_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxMarketPriceCandlesResolutionsViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
