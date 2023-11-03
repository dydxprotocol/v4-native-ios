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

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let view = VStack {

                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(DataLocalizer.localize(path: "APP.ONBOARDING.WELCOME"))
                            .themeFont(fontType: .text, fontSize: .largest)
                            .themeColor(foreground: .textPrimary)

                        Text(DataLocalizer.localize(path: "APP.ONBOARDING.WELCOME_TEXT"))
                            .themeFont(fontSize: .small)
                            .themeColor(foreground: .textTertiary)
                    }

                    HStack {
                        PlatformIconViewModel(type: .asset(name: "onboard_powerful", bundle: Bundle.dydxView),
                                              clip: .circle(background: .layer5, spacing: 30),
                                              size: CGSize(width: 60, height: 60))
                        .createView(parentStyle: style)

                        VStack(alignment: .leading, spacing: 6) {
                            Text(DataLocalizer.localize(path: "APP.ONBOARDING.VALUE_PROP_ADVANCED"))
                                .themeFont(fontSize: .medium)
                                .themeColor(foreground: .textPrimary)
                            Text(DataLocalizer.localize(path: "APP.ONBOARDING.VALUE_PROP_ADVANCED_DESC"))
                                .themeFont(fontSize: .small)
                                .themeColor(foreground: .textTertiary)

                        }

                        Spacer()
                    }
                    .frame(maxWidth: .infinity)

                    HStack {
                        PlatformIconViewModel(type: .asset(name: "onboard_advanced", bundle: Bundle.dydxView),
                                              clip: .circle(background: .layer5, spacing: 30),
                                              size: CGSize(width: 60, height: 60))
                        .createView(parentStyle: style)

                        VStack(alignment: .leading, spacing: 6) {
                            Text(DataLocalizer.localize(path: "APP.ONBOARDING.VALUE_PROP_LIQUID"))
                                .themeFont(fontSize: .medium)
                                .themeColor(foreground: .textPrimary)
                            Text(DataLocalizer.localize(path: "APP.ONBOARDING.VALUE_PROP_LIQUID_DESC"))
                                .themeFont(fontSize: .small)
                                .themeColor(foreground: .textTertiary)
                        }

                        Spacer()
                    }
                    .frame(maxWidth: .infinity)

                    HStack {
                        PlatformIconViewModel(type: .asset(name: "onboard_trustless", bundle: Bundle.dydxView),
                                              clip: .circle(background: .layer5, spacing: 30),
                                              size: CGSize(width: 60, height: 60))
                        .createView(parentStyle: style)

                        VStack(alignment: .leading, spacing: 6) {
                            Text(DataLocalizer.localize(path: "APP.ONBOARDING.VALUE_PROP_TRUSTLESS"))
                                .themeFont(fontSize: .medium)
                                .themeColor(foreground: .textPrimary)
                            Text(DataLocalizer.localize(path: "APP.ONBOARDING.VALUE_PROP_TRUSTLESS_DESC"))
                                .themeFont(fontSize: .small)
                                .themeColor(foreground: .textTertiary)
                        }

                        Spacer()
                    }
                    .frame(maxWidth: .infinity)

                    self.createTOS(parentStyle: style)
                }
                .padding()

                let ctaContent = Text(DataLocalizer.localize(path: "APP.ONBOARDING.GET_STARTED"))
                PlatformButtonViewModel(content: ctaContent.wrappedViewModel,
                                        state: .primary) { [weak self] in
                    self?.ctaAction?()
                }
                                        .createView(parentStyle: style)

                Spacer()
            }
                .padding()
                .themeColor(background: .layer3)
                .makeSheet()

            return AnyView(view.ignoresSafeArea(edges: [.bottom]))
        }
    }

    private func createTOS(parentStyle: ThemeStyle) -> AnyView {
        return AnyView(
            Text(agreementAttributedString)
                .themeFont(fontSize: .small)
                .themeColor(foreground: .textTertiary)
                .leftAligned()
        )
    }

    private var agreementAttributedString: AttributedString {
        let tosText = DataLocalizer.localize(path: "APP.HEADER.TERMS_OF_USE")
        let privacyText = DataLocalizer.localize(path: "APP.ONBOARDING.PRIVACY_POLICY")

        let tos = AttributedString(text: tosText, urlString: tosUrl)
        let privacy = AttributedString(text: privacyText, urlString: privacyPolicyUrl)

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
