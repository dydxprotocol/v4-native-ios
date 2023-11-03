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
    @Published public var placeholderText: String? {
        didSet {
            _placeholder.text = placeholderText
        }
    }

    private let _placeholder = PlaceholderViewModel()

    public init(items: [PlatformViewModel] = [], contentChanged: (() -> Void)? = nil) {
        super.init(items: items,
                   intraItemSeparator: true,
                   firstListItemTopSeparator: true,
                   lastListItemBottomSeparator: true,
                   contentChanged: contentChanged)
        self.placeholder = _placeholder
        self.header = createHeader().wrappedViewModel
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

    private func createHeader() -> some View {
        HStack {
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
