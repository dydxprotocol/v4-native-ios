//
//  dydxTransferDepositView.swift
//  dydxUI
//
//  Created by Rui Huang on 4/7/23.
//  Copyright © 2023 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxTransferDepositViewModel: PlatformViewModel {
    @Published public var chainsComboBox: ChainsComboBoxModel? = ChainsComboBoxModel()
    @Published public var tokensComboBox: TokensComboBoxModel? = TokensComboBoxModel()
    @Published public var amountBox: TransferAmountBoxModel? =
        TransferAmountBoxModel(label: DataLocalizer.localize(path: "APP.GENERAL.AMOUNT"),
                               placeHolder: "0.000",
                               inputType: .decimalDigits)
    @Published public var ctaButton: dydxTradeInputCtaButtonViewModel? = dydxTradeInputCtaButtonViewModel()
    @Published public var validationViewModel: dydxValidationViewModel? = dydxValidationViewModel()

    public init() { }

    public static var previewValue: dydxTransferDepositViewModel {
        let vm = dydxTransferDepositViewModel()
        vm.chainsComboBox = .previewValue
        vm.tokensComboBox = .previewValue
        vm.amountBox = .previewValue
        vm.validationViewModel = .previewValue
        vm.ctaButton = .previewValue
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            return AnyView(
                VStack {
                    Group {
                        VStack(spacing: 12) {
                            self.chainsComboBox?.createView(parentStyle: style)
                            self.tokensComboBox?.createView(parentStyle: style)
                            self.amountBox?.createView(parentStyle: style)
                        }
                    }

                    Spacer()

                    VStack(spacing: -8) {
                        VStack {
                            self.validationViewModel?.createView(parentStyle: style)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .themeColor(background: .layer0)
                        .cornerRadius(12, corners: [.topLeft, .topRight])

                        self.ctaButton?.createView(parentStyle: style)
                    }
                }
            )
        }
    }
}

#if DEBUG
struct dydxTransferDepositView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxTransferDepositViewModel.previewValue
            .createView()
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxTransferDepositView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxTransferDepositViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
