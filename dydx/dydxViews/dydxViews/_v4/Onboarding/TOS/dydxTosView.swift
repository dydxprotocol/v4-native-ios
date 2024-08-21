//
//  dydxTosView.swift
//  dydxUI
//
//  Created by Rui Huang on 8/29/23.
//  Copyright © 2023 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxTosViewModel: PlatformViewModel {
    @Published public var ctaAction: (() -> Void)?
    @Published public var tosUrl: String?
    @Published public var privacyPolicyUrl: String?

    public init() { }

    public static var previewValue: dydxTosViewModel {
        let vm = dydxTosViewModel()
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let view = VStack(spacing: 16) {

                VStack(alignment: .leading, spacing: 8) {
                    Text(DataLocalizer.localize(path: "APP.ONBOARDING.ACKNOWLEDGE_TERMS"))
                        .themeFont(fontSize: .largest)
                }
                .padding(.horizontal, 16)
                .padding(.top, 40)
                .leftAligned()

                ScrollView(showsIndicators: false) {
                    self.createTitle(parentStyle: style)
                    Spacer(minLength: 16)
                    self.createLines(parentStyle: style)
                    Spacer(minLength: 16)
                    self.createFooter(parentStyle: style)
                }
                .padding(.horizontal, 16)

                let buttonContent =
                    Text(DataLocalizer.localize(path: "APP.ONBOARDING.I_AGREE"))
                        .wrappedViewModel
                PlatformButtonViewModel(content: buttonContent) { [weak self] in
                    self?.ctaAction?()
                }
                .createView(parentStyle: style)

                Spacer()
            }
                .padding([.leading, .trailing])
                .padding(.bottom, self.safeAreaInsets?.bottom)
                .themeColor(background: .layer3)
                .makeSheet()

            // make it visible under the tabbar
            return AnyView(view.ignoresSafeArea(edges: [.bottom]))
        }
    }

    private func createTitle(parentStyle: ThemeStyle) -> some View {
        Text(agreementAttributedString)
            .themeFont(fontSize: .small)
            .themeColor(foreground: .textSecondary)
            .leftAligned()
    }

    private func createLines(parentStyle: ThemeStyle) -> some View {
        Group {
            VStack(alignment: .leading, spacing: 12) {
                Text(DataLocalizer.localize(path: "APP.ONBOARDING.TOS_LINE1"))
                    .bulletItem()

                Text(DataLocalizer.localize(path: "APP.ONBOARDING.TOS_LINE2"))
                    .bulletItem()

                Text(DataLocalizer.localize(path: "APP.ONBOARDING.TOS_LINE3"))
                    .bulletItem()

                Text(DataLocalizer.localize(path: "APP.ONBOARDING.TOS_LINE4"))
                    .bulletItem()

                Text(DataLocalizer.localize(path: "APP.ONBOARDING.TOS_LINE5"))
                    .bulletItem()
            }
            .multilineTextAlignment(.leading)
            .themeFont(fontSize: .small)
            .themeColor(foreground: .textSecondary)
            .leftAligned()
            .padding()
        }
        .themeColor(background: .layer3)
        .cornerRadius(12, corners: .allCorners)
    }

    private func createFooter(parentStyle: ThemeStyle) -> some View {
        Text(DataLocalizer.localize(path: "APP.ONBOARDING.TOS_TRANSLATION_DISCLAIMER"))
            .themeFont(fontSize: .small)
            .themeColor(foreground: .textSecondary)
            .leftAligned()
    }

    private var agreementAttributedString: AttributedString {
        let tosText = DataLocalizer.localize(path: "APP.HEADER.TERMS_OF_USE")
        let privacyText = DataLocalizer.localize(path: "APP.ONBOARDING.PRIVACY_POLICY")

        let tos = AttributedString(text: tosText, urlString: tosUrl)
        let privacy = AttributedString(text: privacyText, urlString: privacyPolicyUrl)

        let agreementText = DataLocalizer.localize(path: "APP.ONBOARDING.TOS_TITLE")
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
struct dydxTosView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxTosViewModel.previewValue
            .createView()
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxTosView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxTosViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
