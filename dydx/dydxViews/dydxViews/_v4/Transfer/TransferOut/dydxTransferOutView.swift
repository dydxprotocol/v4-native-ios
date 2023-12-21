//
//  dydxTransferOutView.swift
//  dydxUI
//
//  Created by Rui Huang on 8/15/23.
//  Copyright © 2023 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxTransferOutViewModel: PlatformViewModel {
    @Published public var addressInput: PlatformTextInputViewModel? =
        PlatformTextInputViewModel(label: DataLocalizer.localize(path: "APP.GENERAL.DESTINATION"),
                                   placeHolder: "dydx0000...0000",
                                   truncateMode: .middle)
    @Published public var amountBox: TransferAmountBoxModel? =
        TransferAmountBoxModel(label: DataLocalizer.localize(path: "APP.GENERAL.AMOUNT"),
                               placeHolder: "0.000",
                               inputType: .decimalDigits)
    @Published public var chainsComboBox: ChainsComboBoxModel? =
        ChainsComboBoxModel(icon: PlatformIconViewModel(type: .asset(name: "icon_dydx", bundle: Bundle.dydxView),
                                                        size: CGSize(width: 32, height: 32)),
                            label: DataLocalizer.localize(path: "APP.GENERAL.NETWORK"),
                            text: DataLocalizer.localize(path: "APP.GENERAL.DYDX_CHAIN"))
    @Published public var tokensComboBox: TokensComboBoxModel? =
        TokensComboBoxModel(label: DataLocalizer.localize(path: "APP.GENERAL.ASSET"))

    @Published public var ctaButton: dydxTradeInputCtaButtonViewModel? = dydxTradeInputCtaButtonViewModel()
    @Published public var validationViewModel: dydxValidationViewModel? = dydxValidationViewModel()

    public init() {}

    public static var previewValue: dydxTransferOutViewModel {
        let vm = dydxTransferOutViewModel()
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
                            self.addressInput?.createView(parentStyle: style)
                                .makeInput()
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
                        .themeColor(background: .layer1)
                        .cornerRadius(12, corners: [.topLeft, .topRight])

                        self.ctaButton?.createView(parentStyle: style)
                    }
                }
            )
        }
    }
}

#if DEBUG
struct dydxTransferOutView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxTransferOutViewModel.previewValue
            .createView()
            .themeColor(background: .layer1)
            .environmentObject(themeSettings)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxTransferOutView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxTransferOutViewModel.previewValue
            .createView()
            .themeColor(background: .layer1)
            .environmentObject(themeSettings)
            .previewLayout(.sizeThatFits)
    }
}
#endif
