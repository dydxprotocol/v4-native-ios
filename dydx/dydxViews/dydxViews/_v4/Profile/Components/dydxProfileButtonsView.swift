//
//  dydxProfileButtonsView.swift
//  dydxViews
//
//  Created by Rui Huang on 2/7/23.
//  Copyright © 2023 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities
import SDWebImageSwiftUI

public class dydxProfileButtonsViewModel: PlatformViewModel {
    @Published public var settingsAction: (() -> Void)?
    @Published public var helpAction: (() -> Void)?
    @Published public var walletAction: (() -> Void)?
    @Published public var signOutAction: (() -> Void)?
    @Published public var onboardAction: (() -> Void)?
    @Published public var walletImageUrl: URL?
    @Published public var onboarded: Bool = false

    public init() { }

    public static var previewValue: dydxProfileButtonsViewModel {
        let vm = dydxProfileButtonsViewModel()
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformUI.PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            return AnyView(
                HStack {
                    self.createButton(parentStyle: style,
                                      imageName: "icon_settings",
                                      title: DataLocalizer.localize(path: "APP.EMAIL_NOTIFICATIONS.SETTINGS"),
                                      action: self.settingsAction)

                    self.createButton(parentStyle: style,
                                      imageName: "icon_info",
                                      title: DataLocalizer.localize(path: "APP.HEADER.HELP"),
                                      action: self.helpAction)

                    if let walletImageUrl = self.walletImageUrl {
                        self.createButton(parentStyle: style,
                                          imageUrl: walletImageUrl,
                                          title: DataLocalizer.localize(path: "APP.GENERAL.WALLETS"),
                                          action: self.walletAction)
                    } else {
                        self.createButton(parentStyle: style,
                                          imageName: "icon_wallet",
                                          title: DataLocalizer.localize(path: "APP.GENERAL.WALLETS"),
                                          action: self.walletAction)
                    }

                    if self.onboarded {
                        self.createButton(parentStyle: style,
                                          imageName: "settings_signout",
                                          title: DataLocalizer.localize(path: "APP.GENERAL.SIGN_OUT"),
                                          applyTemplateColor: false,
                                          action: self.signOutAction)
                    } else {
                        self.createButton(parentStyle: style,
                                          imageName: "icon_wallet_connect",
                                          title: DataLocalizer.localize(path: "APP.GENERAL.CONNECT"),
                                          action: self.onboardAction)
                    }
                }
            )
        }
    }

    private func createButton(parentStyle: ThemeStyle, imageName: String, title: String, applyTemplateColor: Bool = true, action: (() -> Void)?) -> some View {
        let icon = PlatformIconViewModel(type: .asset(name: imageName, bundle: Bundle.dydxView),
                                         clip: .circle(background: .layer3, spacing: 24, borderColor: .layer6),
                                         size: CGSize(width: 48, height: 48),
                                         templateColor: applyTemplateColor ? .textSecondary : nil)
        return createButton(parentStyle: parentStyle, icon: icon, title: title, action: action)
    }

    private func createButton(parentStyle: ThemeStyle, imageUrl: URL, title: String, action: (() -> Void)?) -> some View {
        let image = PlatformIconViewModel(type: .url(url: imageUrl),
                                          clip: .circle(background: .layer3, spacing: 0),
                                          size: CGSize(width: 32, height: 32))
        let icon = PlatformIconViewModel(type: .any(viewModel: image),
                                         clip: .circle(background: .layer3, spacing: 16, borderColor: .layer6),
                                         size: CGSize(width: 48, height: 48))
        return createButton(parentStyle: parentStyle, icon: icon, title: title, action: action)
    }

    private func createButton(parentStyle: ThemeStyle, icon: PlatformViewModel, title: String, action: (() -> Void)?) -> some View {
        VStack {
            PlatformButtonViewModel(content: icon,
                                    type: .iconType,
                                    state: .primary,
                                    action: action ?? {})
            .createView(parentStyle: parentStyle)

            Text(title)
                .themeFont(fontSize: .small)
                .themeColor(foreground: .textTertiary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
    }
}

#if DEBUG
struct dydxProfileButtonsView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxProfileButtonsViewModel.previewValue
            .createView()
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxProfileButtonsView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxProfileButtonsViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
