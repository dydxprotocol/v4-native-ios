//
//  dydxSyncDesktopView.swift
//  dydxViews
//
//  Created by Rui Huang on 2/28/23.
//  Copyright © 2023 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxSyncDesktopViewModel: dydxWalletListItemView {
    public init() { }

    public static var previewValue: dydxSyncDesktopViewModel {
        let vm = dydxSyncDesktopViewModel()
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let main = Text(DataLocalizer.localize(path: "APP.SIGN_INTO_MOBILE.SYNC_WITH_DESKTOP"))
            let trailing = Text(DataLocalizer.localize(path: "APP.ONBOARDING.SCAN_QR_CODE_SHORT"))
                    .themeFont(fontSize: .small)
                    .themeColor(foreground: .textTertiary)
            let image = PlatformIconViewModel(type: .asset(name: "icon_qrscan", bundle: Bundle.dydxView),
                                     size: CGSize(width: 36, height: 36))

            return self.createItemView(main: main.wrappedViewModel,
                                  trailing: trailing.wrappedViewModel,
                                  image: image,
                                  style: style)
        }
    }
}

#if DEBUG
struct dydxSyncDesktopView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxSyncDesktopViewModel.previewValue
            .createView()
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxSyncDesktopView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxSyncDesktopViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
