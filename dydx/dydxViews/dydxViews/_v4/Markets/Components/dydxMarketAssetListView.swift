//
//  dydxMarketAssetListView.swift
//  dydxViews
//
//  Created by Rui Huang on 9/29/22.
//  Copyright © 2022 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxMarketAssetListViewModel: PlatformListViewModel {
    public init() {
        super.init(
            intraItemSeparator: false
        )
    }

    public static var previewValue: dydxMarketAssetListViewModel = {
        let vm = dydxMarketAssetListViewModel()
        vm.items = [
            dydxMarketAssetItemViewModel.previewValue,
            dydxMarketAssetItemViewModel.previewValue,
            dydxMarketAssetItemViewModel.previewValue
        ]
        return vm
    }()
}

#if DEBUG
struct dydxMarketAssetListView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxMarketAssetListViewModel.previewValue
            .createView()
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxMarketAssetListView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxMarketAssetListViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
