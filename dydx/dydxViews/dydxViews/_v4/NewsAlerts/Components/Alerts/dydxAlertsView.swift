//
//  dydxAlertsView.swift
//  dydxUI
//
//  Created by Rui Huang on 5/3/23.
//  Copyright © 2023 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxAlertsViewModel: PlatformListViewModel {
    public init() {
        super.init(intraItemSeparator: false)
    }

    public static var previewValue: dydxAlertsViewModel {
        let vm = dydxAlertsViewModel()
        vm.items = [
            dydxAlertItemModel.previewValue,
            dydxAlertItemModel.previewValue
        ]
        return vm
    }
}

#if DEBUG
struct dydxAlertsView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxAlertsViewModel.previewValue
            .createView()
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxAlertsView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxAlertsViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
