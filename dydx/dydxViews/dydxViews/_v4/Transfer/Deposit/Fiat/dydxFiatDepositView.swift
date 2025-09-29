//
//  dydxFiatDepositView.swift
//  dydxUI
//
//  Created by Rui Huang on 29/09/2025.
//  Copyright © 2025 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxFiatDepositViewModel: PlatformViewModel {
    @Published public var cancelAction: (() -> Void)?
    @Published public var ctaAction: (() -> Void)?
    @Published public var ctaEnabled: Bool = true
    @Published public var providerName: String?
    @Published public var providerIcon: String?
    @Published public var providerSubtitle: String?
    @Published public var fee: String?
    @Published public var maxAmount: String?
    
    public init() { }

    public static var previewValue: dydxFiatDepositViewModel {
        let vm = dydxFiatDepositViewModel()
        vm.providerName = "Test Provider"
        vm.providerSubtitle = "Test Subtitle"
        vm.fee = "5%"
        vm.maxAmount = "$100 Max"
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let view = VStack(alignment: .leading, spacing: 24) {
                ZStack {
                    ChevronBackButtonModel(onBackButtonTap: self.cancelAction ?? {})
                        .createView(parentStyle: style)
                        .leftAligned()

                    HStack {
                        Spacer()

                        Text(DataLocalizer.localize(path: "APP.GENERAL.DEPOSIT"))
                            .themeColor(foreground: .textPrimary)
                            .themeFont(fontSize: .larger)

                        Spacer()
                    }
                }
                .padding(.top, 24)

                // ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {

                    Spacer()

                    self.createProviderInfo(style: style)

                    self.createCtaButton(style: style)
                }
            }
                .padding(.horizontal, 24)
                .padding(.bottom, max((self.safeAreaInsets?.bottom ?? 0), 16))
                .themeColor(background: .layer2)
                .ignoresSafeArea(edges: [.bottom])

            return AnyView(view)
        }
    }

    private func createProviderInfo(style: ThemeStyle) -> some View {
        HStack(alignment: .center, spacing: 16) {
            if let icon = providerIcon {
                PlatformIconViewModel(type: .asset(name: icon, bundle: Bundle.dydxView),
                                      size: CGSize(width: 24, height: 24))
                .createView(parentStyle: style)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(providerName ?? "")
                    .themeColor(foreground: .textPrimary)
                    .themeFont(fontType: .plus, fontSize: .medium)

                Text(providerSubtitle ?? "")
                    .themeColor(foreground: .textTertiary)
                    .themeFont(fontSize: .medium)
            }

            Spacer()
        }
    }

    private func createCtaButton(style: ThemeStyle) -> some View {
        let buttonContent = Text(DataLocalizer.localize(path: "APP.DEPOSIT_WITH_FIAT.CONTINUE_TO",
                                                        params: ["PROVIDER": self.providerName ?? "Provider"]))
            .themeColor(foreground: .colorWhite)
            .themeFont(fontType: .base, fontSize: .medium)

        return PlatformButtonViewModel(content: buttonContent.wrappedViewModel,
                                       type: .defaultType(backgroundColor: .colorFadedGreen, cornerRadius: 16),
                                       state: self.ctaEnabled ? .primary : .disabled) { [weak self] in
            if self?.ctaEnabled ?? false {
                self?.ctaAction?()
            }
        }
                                       .createView(parentStyle: style)
                                       .frame(maxWidth: .infinity)
    }
}

#if DEBUG
struct dydxFiatDepositView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxFiatDepositViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxFiatDepositView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxFiatDepositViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
