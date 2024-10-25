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
    @Published public var addressInput: String = ""
    @Published public var amountBox: TransferAmountBoxModel? =
        TransferAmountBoxModel(label: DataLocalizer.localize(path: "APP.GENERAL.AMOUNT"),
                               placeHolder: "0.000",
                               inputType: .decimalDigits)
    @Published public var tokensComboBox: TokensComboBoxModel? =
        TokensComboBoxModel(label: DataLocalizer.localize(path: "APP.GENERAL.ASSET"))
    @Published public var memoBox = MemoBoxModel()

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
        dydxTransferOutView(viewModel: self)
            .wrappedViewModel
            .createView()
    }
}

private struct dydxTransferOutView: View {
    @ObservedObject var viewModel: dydxTransferOutViewModel

    private var chainsStaticInputView: some View {
        let fontType = ThemeFont.FontType.base
        let fontSize = ThemeFont.FontSize.medium
        let fontHeight = ThemeSettings.shared.themeConfig.themeFont.uiFont(of: fontType, fontSize: fontSize)?.lineHeight ?? 32
        return dydxTitledContent(title: DataLocalizer.localize(path: "APP.GENERAL.NETWORK")) {
            HStack(spacing: 8) {
                PlatformIconViewModel(type: .asset(name: "icon_dydx", bundle: Bundle.dydxView),
                                      size: CGSize(width: fontHeight, height: fontHeight))
                .createView()
                Text(DataLocalizer.localize(path: "APP.GENERAL.DYDX_CHAIN"))
                    .themeFont(fontType: fontType, fontSize: fontSize)
                    .themeColor(foreground: .textPrimary)
            }
        }
    }

    var body: some View {
        VStack {
            Group {
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        dydxTitledTextField(title: DataLocalizer.localize(path: "APP.GENERAL.DESTINATION"),
                                            placeholder: "dydx00000000000000",
                                            text: $viewModel.addressInput)
                        chainsStaticInputView
                    }
                    viewModel.tokensComboBox?.createView()
                    viewModel.amountBox?.createView()
                    viewModel.memoBox.createView()
                        .frame(maxWidth: .infinity)
                }
            }

            Spacer()

            VStack(spacing: -8) {
                VStack {
                    viewModel.validationViewModel?.createView()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .themeColor(background: .layer1)
                .cornerRadius(12, corners: [.topLeft, .topRight])

                viewModel.ctaButton?.createView()
            }
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
