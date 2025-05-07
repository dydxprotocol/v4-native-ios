//
//  dydxConnectWalletView.swift
//  dydxUI
//
//  Created by Rui Huang on 5/1/2025.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxConnectWalletViewModel: dydxWalletListItemView {
    public init() { }

    public static var previewValue: dydxConnectWalletViewModel {
        let vm = dydxConnectWalletViewModel()
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let main = Text(DataLocalizer.localize(path: "APP.GENERAL.CONNECT_WALLET"))
            let trailing = HStack {
                self.createIcons(style: style)
                PlatformIconViewModel(type: .system(name: "chevron.right"),
                                      size: CGSize(width: 12, height: 12),
                                      templateColor: .textTertiary)
                .createView(parentStyle: style)
            }
            return self.createItemView(main: main.wrappedViewModel,
                                       trailing: trailing.wrappedViewModel,
                                       image: nil,
                                       style: style)
        }
    }

    private func createIcons(style: ThemeStyle) -> some View {
        HStack(spacing: -12) {
            ForEach(["settings_metamask", "phantom_wallet", "coinbase_wallet", "icon_wc_logo"], id: \.self) { icon in
                return self.createOptionIcon(style: style, icon: icon, templateColor: nil)
            }
        }
    }
}

#if DEBUG
struct dydxConnectWalletView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxConnectWalletViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxConnectWalletView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxConnectWalletViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
