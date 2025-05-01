//
//  dydxSocialView.swift
//  dydxUI
//
//  Created by Rui Huang on 5/1/2025.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxSocialViewModel: dydxWalletListItemView {
    public init() { }

    public static var previewValue: dydxSocialViewModel {
        let vm = dydxSocialViewModel()
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let main = Text(DataLocalizer.localize(path: "APP.WALLETS.EMAIL_OR_SOCIAL"))
            let trailing = PlatformIconViewModel(type: .system(name: "chevron.right"),
                                                 size: CGSize(width: 12, height: 12),
                                                 templateColor: .textTertiary)
            let image = PlatformIconViewModel(type: .asset(name: "icon_wc_logo", bundle: Bundle.dydxView),
                                     size: CGSize(width: 36, height: 36))

            return self.createItemView(main: main.wrappedViewModel,
                                  trailing: trailing,
                                  image: image,
                                  style: style)
        }
    }
}

#if DEBUG
struct dydxSocialView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxSocialViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxSocialView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxSocialViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
