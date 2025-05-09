//
//  dydxPhantomView.swift
//  dydxUI
//
//  Created by Rui Huang on 05/05/2025.
//  Copyright © 2025 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxPhantomViewModel: dydxWalletListItemView {
    public init() { }

    public static var previewValue: dydxPhantomViewModel {
        let vm = dydxPhantomViewModel()
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let main = Text("Phantom")
            let trailing = self.isInstall ?
                createRecommendedLogo(style: style)
                    .wrappedViewModel :
                createInstallLogo(style: style)
                    .wrappedViewModel
            let image = PlatformIconViewModel(type: .asset(name: "phantom_wallet", bundle: Bundle.dydxView),
                                     size: CGSize(width: 24, height: 24))
            return self.createItemView(main: main.wrappedViewModel,
                                  trailing: trailing,
                                  image: image,
                                  style: style)
        }
    }

    private func createRecommendedLogo(style: ThemeStyle) -> some View {
        HStack {
            Text(DataLocalizer.localize(path: "APP.ONBOARDING.RECOMMEND_SOLANA"))
                .themeColor(foreground: .colorPurple)
                .themeFont(fontSize: .small)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .themeColor(background: .colorFadedPurple)
        .cornerRadius(8, corners: .allCorners)
    }
}

#if DEBUG
struct dydxPhantomView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxPhantomViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxPhantomView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxPhantomViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
