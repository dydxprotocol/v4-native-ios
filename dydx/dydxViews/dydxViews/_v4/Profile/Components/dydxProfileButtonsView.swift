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

public class dydxProfileButtonsViewModel: PlatformViewModel {
    @Published public var depositAction: (() -> Void)?
    @Published public var withdrawAction: (() -> Void)?
    @Published public var transferAction: (() -> Void)?
    @Published public var signOutAction: (() -> Void)?
    @Published public var onboardAction: (() -> Void)?
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
                                      imageName: "icon_transfer_deposit",
                                      title: DataLocalizer.localize(path: "APP.GENERAL.DEPOSIT"),
                                      isEnabled: self.onboarded,
                                      action: self.depositAction)

                    self.createButton(parentStyle: style,
                                      imageName: "icon_transfer_withdrawal",
                                      title: DataLocalizer.localize(path: "APP.GENERAL.WITHDRAW"),
                                      isEnabled: self.onboarded,
                                      action: self.withdrawAction)

                    self.createButton(parentStyle: style,
                                      imageName: "icon_transfer_dydx",
                                      title: DataLocalizer.localize(path: "APP.GENERAL.TRANSFER"),
                                      isEnabled: self.onboarded,
                                      action: self.transferAction)

                    if self.onboarded {
                        self.createButton(parentStyle: style,
                                          imageName: "settings_signout",
                                          title: DataLocalizer.localize(path: "APP.GENERAL.SIGN_OUT"),
                                          enabledTemplateColor: nil,
                                          action: self.signOutAction)
                    } else {
                        self.createButton(parentStyle: style,
                                          imageName: "icon_wallet_connect",
                                          title: DataLocalizer.localize(path: "APP.GENERAL.CONNECT"),
                                          backgroundColor: .colorPurple,
                                          enabledTemplateColor: .colorWhite,
                                          action: self.onboardAction)
                    }
                }
            )
        }
    }

    private func createButton(parentStyle: ThemeStyle, imageName: String, title: String, isEnabled: Bool = true, styleKey: String? = nil, backgroundColor: ThemeColor.SemanticColor = .layer3, enabledTemplateColor: ThemeColor.SemanticColor? = .textSecondary, disabledTemplateColor: ThemeColor.SemanticColor? = .textTertiary, action: (() -> Void)?) -> some View {
        let templateColor: ThemeColor.SemanticColor? = isEnabled ? enabledTemplateColor : disabledTemplateColor
        let icon = PlatformIconViewModel(type: .asset(name: imageName, bundle: Bundle.dydxView),
                                     clip: .circle(background: backgroundColor, spacing: 24, borderColor: .layer6),
                                         size: CGSize(width: 48, height: 48),
                                         templateColor: isEnabled ? enabledTemplateColor : disabledTemplateColor)
            .createView(parentStyle: parentStyle)

        let title = Text(title)
            .themeFont(fontSize: .small)
            .themeColor(foreground: templateColor ?? .textSecondary)
            .lineLimit(1)

        let buttonContent = VStack {
            icon
            title
        }
        .frame(maxWidth: .infinity)
        .wrappedViewModel

        return PlatformButtonViewModel(content: buttonContent,
                                       type: .iconType,
                                       state: isEnabled ? .primary : .disabled,
                                       action: action ?? {})
               .createView(parentStyle: parentStyle)
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
