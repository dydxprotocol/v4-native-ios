//
//  dydxCoinbaseView.swift
//  dydxUI
//
//  Created by Rui Huang on 05/05/2025.
//  Copyright © 2025 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxCoinbaseViewModel: dydxWalletListItemView {
    public init() { }

    public static var previewValue: dydxCoinbaseViewModel {
        let vm = dydxCoinbaseViewModel()
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let main = Text("Coinbase")
            let trailing = self.isInstall ?
                Text("").wrappedViewModel :
                createInstallLogo(style: style)
                    .wrappedViewModel
            let image = PlatformIconViewModel(type: .asset(name: "coinbase_wallet", bundle: Bundle.dydxView),
                                              clip: .defaultCircle,
                                              size: CGSize(width: 24, height: 24))
            return self.createItemView(main: main.wrappedViewModel,
                                  trailing: trailing,
                                  image: image,
                                  style: style)
        }
    }
}

#if DEBUG
struct dydxCoinbaseView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxCoinbaseViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxCoinbaseView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxCoinbaseViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
