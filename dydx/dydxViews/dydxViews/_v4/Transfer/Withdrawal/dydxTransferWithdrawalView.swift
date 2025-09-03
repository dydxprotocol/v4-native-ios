//
//  dydxTransferWithdrawalView.swift
//  dydxUI
//
//  Created by Rui Huang on 5/15/23.
//  Copyright © 2023 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxTransferWithdrawalViewModel: PlatformViewModel {
    @Published public var addressInput: PlatformTextInputViewModel? =
        PlatformTextInputViewModel(label: DataLocalizer.localize(path: "APP.GENERAL.DESTINATION"),
                                   truncateMode: .middle)
    @Published public var chainsComboBox: ChainsComboBoxModel? = ChainsComboBoxModel()
    @Published public var tokensComboBox: TokensComboBoxModel? = TokensComboBoxModel()
    @Published public var amountBox: TransferAmountBoxModel? =
        TransferAmountBoxModel(label: DataLocalizer.localize(path: "APP.GENERAL.AMOUNT"),
                               placeHolder: "0.000",
                               inputType: .decimalDigits)
    @Published public var ctaButton: dydxTradeInputCtaButtonViewModel? = dydxTradeInputCtaButtonViewModel()
    @Published public var validationViewModel: dydxValidationViewModel? = dydxValidationViewModel()

    public init() {
        super.init()
        addressInput?.placeHolder = "0x000000000000000000"
    }

    public static var previewValue: dydxTransferWithdrawalViewModel {
        let vm = dydxTransferWithdrawalViewModel()
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
                    VStack {
                        Text(DataLocalizer.localize(path: "APP.GENERAL.WITHDRAW"))
                            .themeColor(foreground: .textPrimary)
                            .themeFont(fontSize: .larger)
                            .centerAligned()
                            .padding(.vertical, 8)
                            .padding(.top, 16)
                            .frame(height: 54)

                        DividerModel().createView(parentStyle: style)
                            .padding(.horizontal, -16)
                    }

                    Group {
                        VStack(spacing: 12) {
                            HStack {
                                self.addressInput?.createView(parentStyle: style)
                                    .makeInput()

                                self.chainsComboBox?.createView(parentStyle: style)
                            }
                            .fixedSize(horizontal: false, vertical: true)

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
                    .padding(.horizontal)
                    .padding(.bottom, max((self.safeAreaInsets?.bottom ?? 0), 16))
                    .themeColor(background: .layer2)
                    .ignoresSafeArea(edges: [.bottom])
            )
        }
    }
}

#if DEBUG
struct dydxTransferWithdrawalView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxTransferWithdrawalViewModel.previewValue
            .createView()
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxTransferWithdrawalView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxTransferWithdrawalViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
