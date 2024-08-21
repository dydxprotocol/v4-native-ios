//
//  dydxTradeInputTimeInForceView.swift
//  dydxViews
//
//  Created by John Huang on 1/4/23.
//

import PlatformUI
import SwiftUI
import Utilities

public class dydxTradeInputTimeInForceViewModel: PlatformPopoverOptionsInputViewModel {
    public static var previewValue: dydxTradeInputTimeInForceViewModel = {
        var options = [InputSelectOption]()
        options.append(InputSelectOption(value: "GTT", string: "APP.TRADE.GTT"))
        options.append(InputSelectOption(value: "IOK", string: "APP.TRADE.IOK"))
        options.append(InputSelectOption(value: "FOC", string: "APP.TRADE.FOC"))
        let vm = dydxTradeInputTimeInForceViewModel(label: "Time in force", value: nil, options: options, onEdited: nil)
        return vm
    }()

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        let view = super.createView(parentStyle: parentStyle, styleKey: styleKey)
        return PlatformView { _ in
            AnyView(view.makeInput())
        }
    }

    public override var selectedItemView: PlatformViewModel {
        let index = index ?? 0
        if let titles = optionTitles, index < titles.count {
            let selectedText = titles[index]

            return HStack {
                    Text(selectedText)
                           .themeFont(fontSize: .medium)
                    Spacer()
                    PlatformIconViewModel(type: .asset(name: "icon_edit", bundle: Bundle.dydxView),
                                          size: CGSize(width: 16, height: 16),
                                          templateColor: .textSecondary)
                        .createView()
                        .padding(.bottom, 16)
                }
                .wrappedViewModel
        }
        return PlatformView.nilViewModel
    }
}

#if DEBUG
struct dydxTradeInputTimeInForceView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxTradeInputTimeInForceViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct ddydxTradeInputTimeInForceView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxTradeInputTimeInForceViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
