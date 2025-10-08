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
    @Published public var amountAction: ((String) -> Void)?
    @Published public var ctaEnabled: Bool = false
    @Published public var providerName: String?
    @Published public var providerIcon: String?
    @Published public var providerSubtitle: String?
    @Published public var fee: String?
    @Published public var amountSubtitle: String?
    @Published public var amountTextInput = PlatformTextInputViewModel(
        placeHolder: "0.00",
        inputType: .decimalDigits,
        focusedOnAppear: true,
        dynamicWidth: true
    )

    public init() { }

    public static var previewValue: dydxFiatDepositViewModel {
        let vm = dydxFiatDepositViewModel()
        vm.providerName = "Test Provider"
        vm.providerSubtitle = "Test Subtitle"
        vm.fee = "5%"
        vm.amountSubtitle = "$100 Max"
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let bottomPadding = max((self.safeAreaInsets?.bottom ?? 0), 16)

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

                VStack(alignment: .leading, spacing: 16) {
                    Spacer()
                    ScrollView(showsIndicators: false) {
                        HStack(spacing: -8) {
                            Spacer()

                            Text("$")
                                .themeColor(foreground: .textPrimary)
                                .themeFont(fontType: .plus, fontSize: .custom(size: 42))
                            self.amountTextInput.createView(parentStyle: style
                                .themeFont(fontType: .plus, fontSize: .custom(size: 42)))

                            Spacer()
                        }
                    }
                    Spacer()

                    VStack(alignment: .leading, spacing: 16) {
                        self.createProviderInfo(style: style)

                        self.createCtaButton(style: style)

                        HStack {
                            Spacer()
                            Text(DataLocalizer.localize(path: "APP.DEPOSIT_WITH_FIAT.CONTINUE_TO_DISCLAIMER",
                                                        params: ["PROVIDER": self.providerName ?? "Provider"]))
                            .themeColor(foreground: .textTertiary)
                            .themeFont(fontSize: .smallest)
                            Spacer()
                        }
                    }
                    .keyboardObserving(offset: -bottomPadding + 16, mode: .yOffset)
                }
            }
                .padding(.horizontal)
                .padding(.bottom, bottomPadding)
                .themeColor(background: .layer2)

            return AnyView(view.ignoresSafeArea(edges: [.bottom]))
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

            VStack(alignment: .trailing, spacing: 2) {
                Text(fee ?? "")
                    .themeColor(foreground: .textPrimary)
                    .themeFont(fontSize: .medium)

                Text(amountSubtitle ?? "")
                    .themeColor(foreground: .textTertiary)
                    .themeFont(fontSize: .medium)
            }
        }
    }

    private func createCtaButton(style: ThemeStyle) -> some View {
        let color: ThemeColor.SemanticColor = self.ctaEnabled ? .colorWhite : .textTertiary
        let buttonContent = Text(DataLocalizer.localize(path: "APP.DEPOSIT_WITH_FIAT.CONTINUE_TO",
                                                        params: ["PROVIDER": self.providerName ?? "Provider"]))
            .themeColor(foreground: color)
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
