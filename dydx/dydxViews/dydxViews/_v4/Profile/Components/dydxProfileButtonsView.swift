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
                                      templateColor: self.onboarded ? .textSecondary : .textTertiary,
                                      textColor: self.onboarded ? .textSecondary : .textTertiary,
                                      action: self.depositAction)

                    self.createButton(parentStyle: style,
                                      imageName: "icon_transfer_withdrawal",
                                      title: DataLocalizer.localize(path: "APP.GENERAL.WITHDRAW"),
                                      templateColor: self.onboarded ? .textSecondary : .textTertiary,
                                      textColor: self.onboarded ? .textSecondary : .textTertiary,
                                      action: self.withdrawAction)

                    self.createButton(parentStyle: style,
                                      imageName: "icon_transfer_dydx",
                                      title: DataLocalizer.localize(path: "APP.GENERAL.TRANSFER"),
                                      templateColor: self.onboarded ? .textSecondary : .textTertiary,
                                      textColor: self.onboarded ? .textSecondary : .textTertiary,
                                      action: self.transferAction)

                    if self.onboarded {
                        self.createButton(parentStyle: style,
                                          imageName: "settings_signout",
                                          title: DataLocalizer.localize(path: "APP.GENERAL.SIGN_OUT"),
                                          templateColor: nil,
                                          textColor: .textSecondary,
                                          action: self.signOutAction)
                    } else {
                        self.createButton(parentStyle: style,
                                          imageName: "icon_wallet_connect",
                                          title: DataLocalizer.localize(path: "APP.GENERAL.CONNECT"),
                                          backgroundColor: .colorPurple,
                                          templateColor: .colorWhite,
                                          textColor: .textSecondary,
                                          action: self.onboardAction)
                    }
                }
            )
        }
    }

    private func createButton(parentStyle: ThemeStyle, imageName: String, title: String, styleKey: String? = nil, backgroundColor: ThemeColor.SemanticColor = .layer3, templateColor: ThemeColor.SemanticColor?, textColor: ThemeColor.SemanticColor, action: (() -> Void)?) -> some View {
        let icon = PlatformIconViewModel(type: .asset(name: imageName, bundle: Bundle.dydxView),
                                     clip: .circle(background: backgroundColor, spacing: 24, borderColor: .layer6),
                                         size: CGSize(width: 48, height: 48),
                                         templateColor: templateColor)
            .createView(parentStyle: parentStyle)

        let title = Text(title)
            .themeFont(fontSize: .small)
            .themeColor(foreground: textColor)
            .lineLimit(1)

        let buttonContent = VStack {
            icon
            title
        }
        .frame(maxWidth: .infinity)
        .wrappedViewModel

        return PlatformButtonViewModel(content: buttonContent,
                                       type: .iconType,
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
