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
    @Published public var oauthViews = [dydxOAuthViewModel]()
    @Published public var onScrollViewCreated: ((UIScrollView) -> Void)?
    @Published public var emailInput: dydxEmailInputViewModel? = dydxEmailInputViewModel()

    public init() { }

    public static var previewValue: dydxSocialLoginViewModel {
        let vm = dydxSocialLoginViewModel()
        vm.connectWallet = .previewValue
        vm.emailInput = .previewValue
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let view = VStack(spacing: 8) {
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

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 12) {
                        self.emailInput?.createView(parentStyle: style)

                        ForEach(self.oauthViews, id: \.self) { item in
                            item.createView(parentStyle: style)
                        }

                        self.createDivider(parentStyle: style)

                        self.connectWallet?.createView(parentStyle: style)

                        Spacer(minLength: 28)
                    }
                    .padding(.top, 16)
                    .introspectScrollView { [weak self] scrollView in
                        self?.onScrollViewCreated?(scrollView)
                    }
                }

                Spacer()
            }
                .padding([.leading, .trailing])
                .themeColor(background: .layer1)

            return AnyView(view.ignoresSafeArea(edges: [.bottom]))
        }
    }

    private func createButton(parentStyle: ThemeStyle,
                              logo_name: String,
                              templateColor: ThemeColor.SemanticColor? = nil,
                              action: (() -> Void)?) -> some View {
        let content = PlatformIconViewModel(type: .asset(name: logo_name, bundle: Bundle.dydxView),
                                            size: CGSize(width: 24, height: 24),
                                            templateColor: templateColor)
        return PlatformButtonViewModel(content: content,
                                       type: .defaultType(cornerRadius: 16),
                                       state: .secondary) {
            action?()
        }
                                       .createView(parentStyle: parentStyle)
    }

    private func createDivider(parentStyle: ThemeStyle) -> some View {
        ZStack(alignment: .center) {
            DividerModel().createView(parentStyle: parentStyle)
            Text(DataLocalizer.localize(path: "APP.GENERAL.OR"))
                .themeColor(foreground: .textTertiary)
                .themeFont(fontSize: .smaller)
                .padding(.horizontal, 8)
                .themeColor(background: .layer1)
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
