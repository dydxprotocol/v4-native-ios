//
//  dydxWalletSecurityView.swift
//
//  Created by Rui Huang on 04/08/2025.
//  Copyright Fambot.  All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxWalletSecurityViewModel: PlatformViewModel {
    public enum LoginMethod: String {
        case email, google, apple
    }
    @Published public var cancelAction: (() -> Void)?
    @Published public var loginMethod: LoginMethod = .email
    @Published public var email: String?
    @Published public var exportSourceAction: (() -> Void)?
    @Published public var exportDydxAction: (() -> Void)?

    public init() { }

    public static var previewValue: dydxWalletSecurityViewModel {
        let vm = dydxWalletSecurityViewModel()
        vm.email = "test@example.com"
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let view = ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    ZStack {
                        HStack {
                            ChevronBackButtonModel(onBackButtonTap: self.cancelAction ?? {})
                                .createView(parentStyle: style)

                            Spacer()
                        }

                        Text(DataLocalizer.localize(path: "APP.GENERAL.ACCOUNT"))
                            .themeColor(foreground: .textPrimary)
                            .themeFont(fontSize: .larger)
                    }
                    .padding(.top, 24)

                    self.createLoginSection(style: style)

                    self.createExportSection(style: style)

                    Spacer()
                }
            }
                .padding(.horizontal, 24)
                .padding(.bottom, max((self.safeAreaInsets?.bottom ?? 0), 16))
                .themeColor(background: .layer1)
                .ignoresSafeArea(edges: [.bottom])

            return AnyView(view)
        }
    }

    private func createLoginSection(style: ThemeStyle) -> some View {
        let title: String
        let subtitle: String
        let icon: String
        switch loginMethod {
        case .email:
            title = DataLocalizer.localize(path: "APP.GENERAL.EMAIL")
            subtitle = DataLocalizer.localize(path: "APP.TURNKEY_ACCOUNT.EMAIL_DESC")
            icon = "icon_email_2"
        case .google:
            title = "Google"
            subtitle = DataLocalizer.localize(path: "APP.TURNKEY_ACCOUNT.GOOGLE_DESC")
            icon = "logo_google"
        case .apple:
            title = "Apple"
            subtitle = DataLocalizer.localize(path: "APP.TURNKEY_ACCOUNT.APPLE_DESC")
            icon = "logo_apple"
        }

        return VStack(alignment: .leading) {
            Text(title)
                .themeColor(foreground: .textPrimary)
                .themeFont(fontSize: .medium)
            Text(subtitle)
                .themeColor(foreground: .textTertiary)
                .themeFont(fontSize: .small)

            HStack(alignment: .center) {
                PlatformIconViewModel(type: .asset(name: icon, bundle: Bundle.dydxView),
                                      size: CGSize(width: 18, height: 18),
                                      templateColor: .textTertiary)
                .createView(parentStyle: style)

                Text(self.email ?? "")
                    .themeFont(fontSize: .medium)
                    .themeColor(foreground: .textSecondary)

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .themeColor(background: .layer3)
            .cornerRadius(12, corners: .allCorners)
        }
    }

    private func createExportSection(style: ThemeStyle) -> some View {
        VStack(alignment: .leading) {
            Text(DataLocalizer.localize(path: "APP.PORTFOLIO.EXPORT"))
                .themeColor(foreground: .textPrimary)
                .themeFont(fontSize: .medium)
            Text(DataLocalizer.localize(path: "APP.TURNKEY_ACCOUNT.EXPORT_DESC"))
                .themeColor(foreground: .textTertiary)
                .themeFont(fontSize: .small)

            HStack(alignment: .center) {
                Text(DataLocalizer.localize(path: "APP.TURNKEY_ACCOUNT.EXPORT_SOURCE_WALLET"))
                    .themeFont(fontSize: .medium)
                    .themeColor(foreground: .textSecondary)

                Spacer()

                PlatformIconViewModel(type: .system(name: "chevron.right"),
                                                     size: CGSize(width: 12, height: 12),
                                                     templateColor: .textTertiary)
                .createView(parentStyle: style)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .themeColor(background: .layer3)
            .cornerRadius(12, corners: .allCorners)
            .onTapGesture { [weak self] in
                self?.exportSourceAction?()
            }

            HStack(alignment: .center) {
                Text(DataLocalizer.localize(path: "APP.TURNKEY_ACCOUNT.EXPORT_DYDX_WALLET"))
                .themeFont(fontSize: .medium)
                .themeColor(foreground: .textSecondary)

                Spacer()

                PlatformIconViewModel(type: .system(name: "chevron.right"),
                                                     size: CGSize(width: 12, height: 12),
                                                     templateColor: .textTertiary)
                .createView(parentStyle: style)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .themeColor(background: .layer3)
            .cornerRadius(12, corners: .allCorners)
            .onTapGesture { [weak self] in
                self?.exportDydxAction?()
            }
        }
    }
}

#if DEBUG
struct dydxWalletSecurityView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxWalletSecurityViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxWalletSecurityView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxWalletSecurityViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
