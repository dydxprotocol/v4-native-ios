//
//  dydxInstantDepositInput.swift
//  dydxUI
//
//  Created by Rui Huang on 21/02/2025.
//  Copyright © 2025 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxInstantDepositInputModel: PlatformViewModel {
    @Published public var token: String?
    @Published public var maxAction: (() -> Void)?
    @Published public var maxAmount: String?
    @Published public var tokenIcon: URL?
    @Published public var chainIcon: URL?
    @Published public var amountInput: PlatformTextInputViewModel?
    @Published public var assetAction: (() -> Void)?

    public init() { }

    public static var previewValue: dydxInstantDepositInputModel {
        let vm = dydxInstantDepositInputModel()
        vm.token = "USDC"
        vm.maxAmount = "$1000.00"
        vm.amountInput = PlatformTextInputViewModel()
        vm.chainIcon = URL(string: "https://v4.testnet.dydx.exchange/chains/ethereum.png")
        vm.tokenIcon = URL(string: "https://v4.testnet.dydx.exchange/currencies/usdc.png")
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let view = HStack {
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Text(DataLocalizer.localize(path: "APP.GENERAL.AMOUNT"))
                            .themeFont(fontSize: .small)

                        Text(self.maxAmount ?? "")
                            .themeFont(fontSize: .small)
                            .themeColor(foreground: .textTertiary)

                        let buttonContent = Text(DataLocalizer.localize(path: "APP.GENERAL.MAX"))
                            .themeFont(fontSize: .small)
                            .themeColor(foreground: .colorPurple)

                        PlatformButtonViewModel(content: buttonContent.wrappedViewModel, type: .iconType, state: .primary) { [weak self] in
                            self?.maxAction?()
                        }
                        .createView(parentStyle: style)
                    }
                    .padding(.horizontal, 16)

                    self.amountInput?.createView(parentStyle: style.themeFont(fontType: .base, fontSize: .largest))
                        .padding(.vertical, -8)
                }

                Spacer()

                let buttonContent = HStack {
                    ZStack {
                        PlatformIconViewModel(type: .url(url: self.tokenIcon), clip: .circle(background: .transparent, spacing: 0), size: CGSize(width: 32, height: 32))
                            .createView(parentStyle: style)

                        PlatformIconViewModel(type: .url(url: self.chainIcon), clip: .circle(background: .transparent, spacing: 0), size: CGSize(width: 14, height: 14))
                            .createView(parentStyle: style)
                            .rightAligned()
                            .bottomAligned()
                    }
                    .frame(width: 32, height: 32)

                    Text(self.token ?? "")
                        .themeColor(foreground: .textPrimary)

                    PlatformIconViewModel(type: .asset(name: "icon_chevron", bundle: Bundle.dydxView), size: CGSize(width: 12, height: 12), templateColor: .textTertiary)
                        .createView(parentStyle: style)

                }
                    .padding(8)
                    .themeColor(background: .layer5)
                    .borderAndClip(style: .cornerRadius(8), borderColor: .layer6)

                PlatformButtonViewModel(content: buttonContent.wrappedViewModel, type: .iconType, state: .primary) { [weak self] in
                    self?.assetAction?()
                }
                .createView(parentStyle: style)
            }
                .padding(.vertical, 8)
                .padding(.trailing, 16)
                .makeInput()

            return AnyView(view)
        }
    }
}

#if DEBUG
struct dydxInstantDepositInput_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxInstantDepositInputModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxInstantDepositInput_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxInstantDepositInputModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
