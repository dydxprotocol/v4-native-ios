//
//  dydxInstantDepositView.swift
//  dydxUI
//
//  Created by Rui Huang on 21/02/2025.
//  Copyright © 2025 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxInstantDepositViewModel: PlatformViewModel {
    @Published public var uiStyle = DepositSelectorViewStyle.display_only
    @Published public var input: dydxInstantDepositInputModel? = dydxInstantDepositInputModel()
    @Published public var selector: dydxInstantDepositSelectorModel? =
        dydxInstantDepositSelectorModel()
    @Published public var ctaButton: dydxTradeInputCtaButtonViewModel? = dydxTradeInputCtaButtonViewModel()
    @Published public var validationViewModel: dydxValidationViewModel? = dydxValidationViewModel()
    @Published public var showConnectWallet = false
    @Published public var connectWalletAction: (() -> Void)?
    @Published public var freeDepositWarningMessage: String?

    public init() { }

    public static var previewValue: dydxInstantDepositViewModel {
        let vm = dydxInstantDepositViewModel()
        vm.input = .previewValue
        vm.selector = .previewValue
        vm.validationViewModel = .previewValue
        vm.ctaButton = .previewValue
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let view = VStack(spacing: 16) {
                VStack {
                    Text(DataLocalizer.localize(path: "APP.GENERAL.DEPOSIT"))
                        .themeColor(foreground: .textPrimary)
                        .themeFont(fontSize: .larger)
                        .centerAligned()
                        .padding(.vertical, 8)
                        .padding(.top, 16)
                        .frame(height: 54)

                    DividerModel().createView(parentStyle: style)
                        .padding(.horizontal, -16)
                }

                if self.showConnectWallet {
                    HStack(spacing: 8) {
                        Text(DataLocalizer.localize(path: "APP.V4_DEPOSIT.MOBILE_WALLET_REQUIRED"))
                            .themeFont(fontSize: .medium)

                        let content = Text(DataLocalizer.localize(path: "APP.GENERAL.CONNECT_WALLET")).lineLimit(1).wrappedViewModel
                        PlatformButtonViewModel(content: content,
                                                type: .defaultType(fillWidth: false)) { [weak self] in
                            self?.connectWalletAction?()
                        }
                                                .createView(parentStyle: style)
                    }
                } else {
                    switch self.uiStyle {
                    case .toggle:
                        self.input?.createView(parentStyle: style)
                        self.selector?.createView(parentStyle: style)
                    case .display_only:
                        ZStack(alignment: .bottom) {
                            self.selector?.createView(parentStyle: style)
                                .padding()
                                .padding(.top, 6)
                                .themeColor(background: .layer1)
                                .cornerRadius(12, corners: [.bottomLeft, .bottomRight])

                            VStack {
                                self.input?.createView(parentStyle: style)
                                    .topAligned()
                                Spacer(minLength: 48)
                            }
                        }
                        .frame(height: 120)

                        if let freeDepositWarningMessage = self.freeDepositWarningMessage {
                            InlineAlertViewModel(.init(title: nil,
                                                       body: freeDepositWarningMessage,
                                                       level: .custom(tabColor: .colorPurple, backgroundColor: .colorFadedPurple)))
                            .createView(parentStyle: style)
                        }
                    }
                }

                Spacer()

                VStack(spacing: -8) {
                    VStack {
                        self.validationViewModel?.createView(parentStyle: style)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .themeColor(background: .layer1)
                    .cornerRadius(12, corners: [.topLeft, .topRight])

                    self.ctaButton?.createView(parentStyle: style)
                }
            }
                .padding(.horizontal)
                .padding(.bottom, max((self.safeAreaInsets?.bottom ?? 0), 16))
                .themeColor(background: .layer2)
                .ignoresSafeArea(edges: [.bottom])

            return AnyView(view)
        }
    }
}

#if DEBUG
struct dydxInstantDepositView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxInstantDepositViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxInstantDepositView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxInstantDepositViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
