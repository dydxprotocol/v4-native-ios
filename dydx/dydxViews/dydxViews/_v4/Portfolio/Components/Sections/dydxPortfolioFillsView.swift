//
//  dydxPortfolioFillsView.swift
//  dydxViews
//
//  Created by Rui Huang on 1/5/23.
//  Copyright © 2023 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxPortfolioFillsViewModel: PlatformListViewModel {
    @Published public var placeholderText: String?

    public override var placeholder: PlatformViewModel? {
        let vm = PlaceholderViewModel()
        vm.text = placeholderText
        return vm
    }

    public init(items: [PlatformViewModel] = [], contentChanged: (() -> Void)? = nil) {
        super.init(items: items,
                   intraItemSeparator: true,
                   firstListItemTopSeparator: true,
                   lastListItemBottomSeparator: true,
                   contentChanged: contentChanged)
        self.width = UIScreen.main.bounds.width - 16
    }

    public static var previewValue: dydxPortfolioFillsViewModel {
        let vm = dydxPortfolioFillsViewModel {}
        vm.items = [
            SharedFillViewModel.previewValue,
            SharedFillViewModel.previewValue
        ]
        return vm
    }

    public override var header: PlatformViewModel? {
        guard items.count > 0 else { return nil }
        return HStack {
            HStack {
                Text(DataLocalizer.localize(path: "APP.GENERAL.TIME"))
                Spacer()
            }
            .frame(width: 80)
            Text(DataLocalizer.localize(path: "APP.GENERAL.TYPE_AMOUNT"))
            Spacer()
            Text(DataLocalizer.localize(path: "APP.GENERAL.PRICE_FEE"))
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
        .themeFont(fontSize: .small)
        .themeColor(foreground: .textTertiary)
        .wrappedViewModel
    }
}

#if DEBUG
struct dydxPortfolioFillsView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxPortfolioFillsViewModel.previewValue
            .createView()
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxPortfolioFillsView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxPortfolioFillsViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
