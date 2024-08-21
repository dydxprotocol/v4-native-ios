//
//  dydxTradeInputOrderTypeView.swift
//  dydxViews
//
//  Created by John Huang on 1/4/23.
//

import PlatformUI
import SwiftUI
import Utilities

public class dydxTradeInputOrderTypeViewModel: PlatformButtonOptionsInputViewModel {
    public static var previewValue: dydxTradeInputOrderTypeViewModel = {
        var options = [InputSelectOption]()
        options.append(InputSelectOption(value: "X", string: "APP.TRADE.MARKET_ORDER"))
        let vm = dydxTradeInputOrderTypeViewModel(label: nil, value: nil, options: options, onEdited: nil)
        return vm
    }()

    public override func unselected(item: String) -> PlatformViewModel {
        TabItemViewModel(value: .text(item), isSelected: false)
    }

    public override func selected(item: String) -> PlatformViewModel {
        TabItemViewModel(value: .text(item), isSelected: true)
    }
}

#if DEBUG
struct dydxTradeInputOrderTypeView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxTradeInputOrderTypeViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxTradeInputOrderTypeView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxTradeInputOrderTypeViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
