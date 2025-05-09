//
//  dydxOAuthView.swift
//  dydxUI
//
//  Created by Rui Huang on 05/05/2025.
//  Copyright © 2025 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxOAuthViewModel: dydxWalletListItemView, Hashable {
    @Published public var providerName: String?
    @Published public var providerIcon: String?
    @Published public var iconTemplateColor: ThemeColor.SemanticColor?

    public static func == (lhs: dydxOAuthViewModel, rhs: dydxOAuthViewModel) -> Bool {
        lhs.providerName == rhs.providerName &&
        lhs.providerIcon == rhs.providerIcon &&
        lhs.iconTemplateColor == rhs.iconTemplateColor
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(providerName)
        hasher.combine(providerIcon)
        hasher.combine(iconTemplateColor)
    }

    public init(providerName: String? = nil, providerIcon: String? = nil, iconTemplateColor: ThemeColor.SemanticColor? = nil) {
        self.providerName = providerName
        self.providerIcon = providerIcon
        self.iconTemplateColor = iconTemplateColor
    }

    public init() { }

    public static var previewValue: dydxOAuthViewModel {
        let vm = dydxOAuthViewModel()
        vm.providerName = "Google"
        vm.providerIcon = "logo_google"
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let main = Text("")
            let trailing = HStack {
                Text(DataLocalizer.localize(path: "APP.ONBOARDING.SIGN_IN_WITH_PROVIDER",
                                            params: ["PROVIDER": self.providerName ?? ""]))
                .themeColor(foreground: .textTertiary)
                .themeFont(fontSize: .medium)
                PlatformIconViewModel(type: .system(name: "chevron.right"),
                                                     size: CGSize(width: 12, height: 12),
                                                     templateColor: .textTertiary)
                .createView(parentStyle: style)
            }
            let image = PlatformIconViewModel(type: .asset(name: self.providerIcon, bundle: Bundle.dydxView),
                                              size: CGSize(width: 28, height: 28),
                                              templateColor: self.iconTemplateColor)

            return self.createItemView(main: main.wrappedViewModel,
                                       trailing: trailing.wrappedViewModel,
                                       image: image,
                                       style: style)
        }
    }
}

#if DEBUG
struct dydxOAuthView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxOAuthViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxOAuthView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxOAuthViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
