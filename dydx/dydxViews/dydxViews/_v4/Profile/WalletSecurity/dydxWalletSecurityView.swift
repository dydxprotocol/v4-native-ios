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
    @Published public var loginAction: (() -> Void)?
    @Published public var email: String?
    @Published public var exportSourceAction: (() -> Void)?
    @Published public var exportDydxAction: (() -> Void)?
    @Published public var sourceAddress: String?
    @Published public var dydxAddress: String?
    @Published public var showBackbutton: Bool = false

    public init() { }

    public static var previewValue: dydxWalletSecurityViewModel {
        let vm = dydxWalletSecurityViewModel()
        vm.email = "test@example.com"
        vm.sourceAddress = "0x1234567890"
        vm.dydxAddress = "0x9876543210"
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let view = ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    ZStack {
                        HStack {
                            if self.showBackbutton {
                                ChevronBackButtonModel(onBackButtonTap: self.cancelAction ?? {})
                                    .createView(parentStyle: style)
                            }

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
        let templateColor: ThemeColor.SemanticColor?
        switch loginMethod {
        case .email:
            title = DataLocalizer.localize(path: "APP.GENERAL.EMAIL")
            subtitle = DataLocalizer.localize(path: "APP.TURNKEY_ACCOUNT.EMAIL_DESC")
            icon = "icon_email_2"
            templateColor = .textTertiary
        case .google:
            title = "Google"
            subtitle = DataLocalizer.localize(path: "APP.TURNKEY_ACCOUNT.GOOGLE_DESC")
            icon = "logo_google"
            templateColor = nil
        case .apple:
            title = "Apple"
            subtitle = DataLocalizer.localize(path: "APP.TURNKEY_ACCOUNT.APPLE_DESC")
            icon = "logo_apple"
            templateColor = .textTertiary
        }

        return VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .themeColor(foreground: .textPrimary)
                    .themeFont(fontSize: .medium)
                Text(subtitle)
                    .themeColor(foreground: .textTertiary)
                    .themeFont(fontSize: .small)
            }

            HStack(alignment: .center) {
                PlatformIconViewModel(type: .asset(name: icon, bundle: Bundle.dydxView),
                                      size: CGSize(width: 18, height: 18),
                                      templateColor: templateColor)
                .createView(parentStyle: style)

                Text(self.email ?? "")
                    .themeFont(fontSize: .medium)
                    .themeColor(foreground: .textSecondary)
                    .lineLimit(1)
                    .truncationMode(.middle)

                Spacer()

                HStack(alignment: .center, spacing: 4) {
                    PlatformIconViewModel(type: .asset(name: "icon_verified", bundle: Bundle.dydxView),
                                                         size: CGSize(width: 16, height: 16),
                                                         templateColor: .colorGreen)
                    .createView(parentStyle: style)

                    Text(DataLocalizer.localize(path: "APP.EMAIL_NOTIFICATIONS.VERIFIED"))
                        .themeFont(fontSize: .smallest)
                        .themeColor(foreground: .colorGreen)
                        .lineLimit(1)
                        .truncationMode(.middle)
                }
                .padding(.horizontal, 9)
                .padding(.vertical, 4)
                .themeColor(background: .layer5)
                .clipShape(.capsule)

//                PlatformIconViewModel(type: .system(name: "chevron.right"),
//                                                     size: CGSize(width: 12, height: 12),
//                                                     templateColor: .textTertiary)
//                .createView(parentStyle: style)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .themeColor(background: .layer3)
            .cornerRadius(12, corners: .allCorners)
        }
//        .onTapGesture { [weak self] in
//            self?.loginAction?()
//        }
    }

    private func createExportSection(style: ThemeStyle) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(DataLocalizer.localize(path: "APP.PORTFOLIO.EXPORT"))
                    .themeColor(foreground: .textPrimary)
                    .themeFont(fontSize: .medium)
                Text(DataLocalizer.localize(path: "APP.TURNKEY_ACCOUNT.EXPORT_DESC"))
                    .themeColor(foreground: .textTertiary)
                    .themeFont(fontSize: .small)
            }

            HStack(alignment: .center) {
                Text(DataLocalizer.localize(path: "APP.TURNKEY_ACCOUNT.EXPORT_SOURCE_WALLET"))
                    .themeFont(fontSize: .medium)
                    .themeColor(foreground: .textSecondary)

                Spacer()

                if let sourceAddress {
                    Text(sourceAddress)
                        .themeFont(fontSize: .smallest)
                        .themeColor(foreground: .textSecondary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                        .frame(maxWidth: 96)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 4)
                        .themeColor(background: .layer5)
                        .clipShape(.capsule)
                }

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

                if let dydxAddress {
                    Text(dydxAddress)
                        .themeFont(fontSize: .smallest)
                        .themeColor(foreground: .colorPurple)
                        .lineLimit(1)
                        .truncationMode(.middle)
                        .frame(maxWidth: 96)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 4)
                        .themeColor(background: .layer5)
                        .clipShape(.capsule)
                }

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
