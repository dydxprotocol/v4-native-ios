//
//  dydxWalletView.swift
//  dydxViews
//
//  Created by Rui Huang on 2/28/23.
//  Copyright © 2023 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxWalletViewModel: dydxWalletListItemView {
    @Published public var shortName: String?
    @Published public var imageUrl: URL?
    @Published public var installed: Bool = true

    public static var previewValue: dydxWalletViewModel {
        let vm = dydxWalletViewModel()
        vm.shortName = "Metamask"
        vm.imageUrl = URL(string: "https://s3.amazonaws.com/dydx.exchange/logos/walletconnect/lg/9d373b43ad4d2cf190fb1a774ec964a1addf406d6fd24af94ab7596e58c291b2.jpeg")
        vm.installed = true
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let main = Text(self.shortName ?? "")
            let trailing = self.installed ?
                Text(DataLocalizer.localize(path: "APP.GENERAL.INSTALLED"))
                    .themeFont(fontSize: .small)
                    .themeColor(foreground: .textTertiary):
                Text(DataLocalizer.localize(path: "APP.GENERAL.INSTALL"))
                    .themeFont(fontSize: .small)
                    .themeColor(foreground: .textSecondary)
            let image = PlatformIconViewModel(type: .url(url: self.imageUrl),
                                     clip: .defaultCircle,
                                     size: CGSize(width: 36, height: 36))

            return self.createItemView(main: main.wrappedViewModel,
                                  trailing: trailing.wrappedViewModel,
                                  image: image,
                                  style: style)
        }
    }
}

#if DEBUG
struct dydxWalletView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxWalletViewModel.previewValue
            .createView()
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxWalletView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxWalletViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
