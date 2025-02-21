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
    @Published public var input: dydxInstantDepositInputModel?
    @Published public var selector: dydxInstantDepositSelectorModel?
    @Published public var ctaButton: dydxTradeInputCtaButtonViewModel? = dydxTradeInputCtaButtonViewModel()
    @Published public var validationViewModel: dydxValidationViewModel? = dydxValidationViewModel()
    @Published public var showConnectWallet = false
    @Published public var connectWalletAction: (() -> Void)?

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
                self.input?.createView(parentStyle: style)
                self.selector?.createView(parentStyle: style)

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
