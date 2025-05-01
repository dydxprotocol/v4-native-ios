//
//  dydxSocialLoginView.swift
//  dydxUI
//
//  Created by Rui Huang on 5/1/2025.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxSocialLoginViewModel: PlatformViewModel {
    @Published public var connectWallet: dydxConnectWalletViewModel?
    @Published public var googleAction: (() -> Void)?

    public init() { }

    public static var previewValue: dydxSocialLoginViewModel {
        let vm = dydxSocialLoginViewModel()
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let view = VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(DataLocalizer.localize(path: "APP.ONBOARDING.LOGIN_SIGNUP"))
                        .themeFont(fontSize: .largest)

                    Text(DataLocalizer.localize(path: "APP.ONBOARDING.LOGIN_SIGNUP_TEXT"))
                        .themeFont(fontSize: .small)
                        .themeColor(foreground: .textTertiary)
                }
                .padding(.horizontal, 16)
                .padding(.top, 40)
                .leftAligned()

                HStack {
                    let content = PlatformIconViewModel(type: .asset(name: "logo_google", bundle: Bundle.dydxView),
                                                        size: CGSize(width: 24, height: 24))
                    PlatformButtonViewModel(content: content,
                                            type: .defaultType(cornerRadius: 16),
                                            state: .secondary) { [weak self] in
                        self?.googleAction?()
                    }.createView(parentStyle: style)
                }

                self.createDivider(parentStyle: style)

                self.connectWallet?.createView(parentStyle: style)

                Spacer()
            }
                .padding([.leading, .trailing])
                .themeColor(background: .layer3)

            return AnyView(view.ignoresSafeArea(edges: [.bottom]))
        }
    }

    private func createDivider(parentStyle: ThemeStyle) -> some View {
        ZStack(alignment: .center) {
            DividerModel().createView(parentStyle: parentStyle)
            Text(DataLocalizer.localize(path: "APP.GENERAL.OR"))
                .themeColor(foreground: .textTertiary)
                .themeFont(fontSize: .smaller)
                .padding(.horizontal, 8)
                .themeColor(background: .layer3)
        }
    }
}

#if DEBUG
struct dydxSocialLoginView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxSocialLoginViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxSocialLoginView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxSocialLoginViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
