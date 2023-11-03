//
//  dydxPortfolioTransfersViewModel.swift
//  dydxViews
//
//  Created by Michael Maguire on 9/11/23.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxPortfolioTransfersViewModel: PlatformListViewModel {
    @Published public var placeholderText: String? {
        didSet {
            _placeholder.text = placeholderText
        }
    }

    private let _placeholder = PlaceholderViewModel()

    public init(items: [PlatformViewModel] = [], contentChanged: (() -> Void)? = nil) {
        super.init(items: items,
                   placeholder: _placeholder,
                   intraItemSeparator: true,
                   firstListItemTopSeparator: true,
                   lastListItemBottomSeparator: true,
                   contentChanged: contentChanged)
        self.width = UIScreen.main.bounds.width - 16
    }

    public static var previewValue: dydxPortfolioTransfersViewModel {
        let vm = dydxPortfolioTransfersViewModel()
        return vm
    }
}

#if DEBUG
struct dydxPortfolioTransfersView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxPortfolioTransfersViewModel.previewValue
            .createView()
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxPortfolioTransfersView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxPortfolioTransfersViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
