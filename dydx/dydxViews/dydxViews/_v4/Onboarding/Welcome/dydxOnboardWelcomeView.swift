//
//  dydxOnboardWelcomeView.swift
//  dydxViews
//
//  Created by Rui Huang on 3/22/23.
//  Copyright © 2023 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxOnboardWelcomeViewModel: PlatformViewModel {
    @Published public var ctaAction: (() -> Void)?
    @Published public var tosUrl: String?
    @Published public var privacyPolicyUrl: String?

    public init() { }

    public static var previewValue: dydxOnboardWelcomeViewModel {
        let vm = dydxOnboardWelcomeViewModel()
        return vm
    }

    private func createHeader() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(DataLocalizer.localize(path: "APP.ONBOARDING.WELCOME"))
                .themeFont(fontType: .plus, fontSize: .largest)
                .themeColor(foreground: .textPrimary)
                .leftAligned()
            Text(DataLocalizer.localize(path: "APP.ONBOARDING.WELCOME_TEXT"))
                .themeFont(fontSize: .small)
                .themeColor(foreground: .textTertiary)
                .frame(minHeight: 48)
                .leftAligned()
        }
        .padding(.horizontal, 8)
        .padding(.top, 16)
        .frame(maxWidth: .infinity)
    }

    private func createHighlightView(assetName: String, titlePath: String, subtitlePath: String, style: ThemeStyle) -> some View {
        HStack(spacing: 16) {
            PlatformIconViewModel(type: .asset(name: assetName, bundle: Bundle.dydxView),
                                  clip: .circle(background: .layer5, spacing: 30),
                                  size: CGSize(width: 60, height: 60),
                                  templateColor: .textPrimary)
            .createView(parentStyle: style)

            VStack(alignment: .leading, spacing: 6) {
                Text(DataLocalizer.localize(path: titlePath))
                    .themeFont(fontSize: .medium)
                    .themeColor(foreground: .textPrimary)
                Text(DataLocalizer.localize(path: subtitlePath))
                    .themeFont(fontSize: .small)
                    .themeColor(foreground: .textTertiary)
            }

            Spacer()
        }
        .padding(.horizontal, 8)
        .frame(maxWidth: .infinity)
    }

    private func createCta(style: ThemeStyle) -> some View {
        let ctaContent = Text(DataLocalizer.localize(path: "APP.COMPLIANCE_MODAL.CONTINUE"))
        return PlatformButtonViewModel(content: ctaContent.wrappedViewModel,
                                       type: .defaultType(minHeight: 56),
                                state: .primary) { [weak self] in
            self?.ctaAction?()
        }
                                .createView(parentStyle: style)
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let view = VStack(alignment: .leading, spacing: 0) {
                VStack(spacing: 24) {
                    self.createHeader()
                        .padding(.top, 16)
                    self.createHighlightView(assetName: "onboard_advanced", titlePath: "APP.ONBOARDING.VALUE_PROP_LIQUID", subtitlePath: "APP.ONBOARDING.VALUE_PROP_LIQUID_DESC", style: style)
                    self.createHighlightView(assetName: "onboard_powerful", titlePath: "APP.ONBOARDING.VALUE_PROP_ADVANCED", subtitlePath: "APP.ONBOARDING.VALUE_PROP_ADVANCED_DESC", style: style)
                    self.createHighlightView(assetName: "onboard_trustless", titlePath: "APP.ONBOARDING.VALUE_PROP_TRUSTLESS", subtitlePath: "APP.ONBOARDING.VALUE_PROP_TRUSTLESS_DESC", style: style)
                    self.createTOS(parentStyle: style)
                    self.createCta(style: style)
                }
                Spacer()
            }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .themeColor(background: .layer3)
                .makeSheet()

            return AnyView(view.ignoresSafeArea(edges: [.bottom]))
        }
    }

    private func createTOS(parentStyle: ThemeStyle) -> some View {
        Text(agreementAttributedString)
            .themeFont(fontSize: .small)
            .themeColor(foreground: .textTertiary)
            .leftAligned()
            .fixedSize(horizontal: false, vertical: true)
    }

    private var agreementAttributedString: AttributedString {
        let tosText = DataLocalizer.localize(path: "APP.HEADER.TERMS_OF_USE")
        let privacyText = DataLocalizer.localize(path: "APP.ONBOARDING.PRIVACY_POLICY")

        let tos = AttributedString(text: tosText, urlString: tosUrl, foregroundColor: ThemeColor.SemanticColor.colorPurple.uiColor)
        let privacy = AttributedString(text: privacyText, urlString: privacyPolicyUrl, foregroundColor: ThemeColor.SemanticColor.colorPurple.uiColor)

        let agreementText = DataLocalizer.localize(path: "APP.ONBOARDING.YOU_AGREE_TO_TERMS")
        var result = AttributedString(agreementText)
        if let range = result.range(of: "{TERMS_LINK}") {
            result.replaceSubrange(range, with: tos)
        }
        if let range = result.range(of: "{PRIVACY_POLICY_LINK}") {
            result.replaceSubrange(range, with: privacy)
        }

        return result
    }
}

#if DEBUG
struct dydxOnboardWelcomeView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxOnboardWelcomeViewModel.previewValue
            .createView()
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxOnboardWelcomeView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxOnboardWelcomeViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
