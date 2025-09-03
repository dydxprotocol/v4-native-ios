//
//  DydxDepositPromptView.swift
//  dydxUI
//
//  Created by Rui Huang on 28/08/2025.
//  Copyright © 2025 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxDepositPromptViewModel: PlatformViewModel {
    public enum LoginMode: String {
        case apple, google, email
    }

    @Published public var mode: LoginMode?
    @Published public var user: String?
    @Published public var onCtaAction: (() -> Void)?

    public init() { }

    public static var previewValue: dydxDepositPromptViewModel {
        let vm = dydxDepositPromptViewModel()
        vm.mode = .apple
        vm.user = "Test String"
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let view = ZStack(alignment: .top) {
                Image(themedImageBaseName: "texture", bundle: .dydxView)
                    .resizable()
                    .scaledToFit()
                    .opacity(0.2)
                    .ignoresSafeArea()

                VStack(alignment: .center, spacing: 16) {

                    PlatformIconViewModel(type: .asset(name: "stars", bundle: Bundle.dydxView),
                                          size: CGSize(width: 43, height: 43))
                    .createView(parentStyle: style)
                    .padding(.top, 16)

                    VStack(alignment: .center) {
                        Text(DataLocalizer.localize(path: "APP.TURNKEY_ONBOARD.WELCOME_TO_DYDX"))
                            .themeFont(fontType: .plus, fontSize: .larger)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [ThemeColor.SemanticColor.textPrimary.color, ThemeColor.SemanticColor.colorPurple.color],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )

                        Text(DataLocalizer.localize(path: "APP.TURNKEY_ONBOARD.USER_SIGNED_IN_BELOW"))
                            .themeColor(foreground: .textTertiary)
                            .themeFont(fontSize: .medium)
                    }

                    HStack(alignment: .center) {
                        switch self.mode {
                        case .apple:
                            PlatformIconViewModel(type: .asset(name: "logo_apple", bundle: Bundle.dydxView),
                                                  size: CGSize(width: 16, height: 16),
                                                  templateColor: .textPrimary)
                            .createView(parentStyle: style)
                        case .google:
                            PlatformIconViewModel(type: .asset(name: "logo_google", bundle: Bundle.dydxView),
                                                  size: CGSize(width: 16, height: 16))
                            .createView(parentStyle: style)
                        case .email:
                            PlatformIconViewModel(type: .asset(name: "icon_email", bundle: Bundle.dydxView),
                                                  size: CGSize(width: 16, height: 16),
                                                  templateColor: .textPrimary)
                            .createView(parentStyle: style)
                        default:
                            EmptyView()
                        }

                        Text(self.user ?? "")
                            .themeColor(foreground: .textPrimary)
                            .themeFont(fontSize: .medium)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .themeColor(background: .layer3)
                    .borderAndClip(style: .cornerRadius(12), borderColor: .layer4)
                    .padding(.bottom, 16)

                    let content = Text(DataLocalizer.localize(path: "APP.TURNKEY_ONBOARD.DEPOSIT_AND_TRADE"))
                        .themeColor(foreground: .colorWhite)
                    PlatformButtonViewModel(content: content.wrappedViewModel,
                                            type: .defaultType(cornerRadius: 16)) { [weak self] in
                        self?.onCtaAction?()
                    }
                                            .createView(parentStyle: style)
                }
                .padding(.horizontal)
                .padding(.top, 40)
                .padding(.bottom, max((self.safeAreaInsets?.bottom ?? 0), 16))
            }
                .themeColor(background: .layer3)
                .makeSheet(sheetStyle: .fitSize)

            // make it visible under the tabbar
            return AnyView(view.ignoresSafeArea(edges: [.bottom]))
        }
    }
}

#if DEBUG
struct DydxDepositPromptView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxDepositPromptViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct DydxDepositPromptView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxDepositPromptViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
