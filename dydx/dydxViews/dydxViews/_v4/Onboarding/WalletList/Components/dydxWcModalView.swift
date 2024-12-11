//
//  dydxWcModalView.swift
//  dydxUI
//
//  Created by Rui Huang on 10/12/2024.
//  Copyright © 2024 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxWcModalViewModel: dydxWalletListItemView {
    @Published public var text: String?

    public init() { }

    public static var previewValue: dydxWcModalViewModel {
        let vm = dydxWcModalViewModel()
        vm.text = "Test String"
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let main = Text(DataLocalizer.localize(path: "APP.WALLETS.WALLET_CONNECT_2"))
            let trailing = Text(DataLocalizer.localize(path: "APP.GENERAL.RECOMMENDED"))
                    .themeFont(fontSize: .small)
                    .themeColor(foreground: .textTertiary)
            let image = PlatformIconViewModel(type: .asset(name: "icon_wc_logo", bundle: Bundle.dydxView),
                                     size: CGSize(width: 36, height: 36))

            return self.createItemView(main: main.wrappedViewModel,
                                  trailing: trailing.wrappedViewModel,
                                  image: image,
                                  style: style)
        }
    }
}

#if DEBUG
struct dydxWcModalView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxWcModalViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxWcModalView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxWcModalViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
