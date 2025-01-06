//
//  dydxAdjustMarginInputView.swift
//  dydxUI
//
//  Created by Rui Huang on 08/05/2024.
//  Copyright © 2024 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxAdjustMarginInputViewModel: PlatformViewModel {
    @Published public var sharedMarketViewModel: SharedMarketViewModel? = SharedMarketViewModel()
    @Published public var marginDirection: dydxAdjustMarginDirectionViewModel? = dydxAdjustMarginDirectionViewModel()
    @Published public var marginPercentage: dydxAdjustMarginPercentageViewModel? = dydxAdjustMarginPercentageViewModel()
    @Published public var amount: PlatformTextInputViewModel? = PlatformTextInputViewModel(inputType: .decimalDigits)
    @Published public var amountReceipt: dydxAdjustMarginReceiptViewModel? = dydxAdjustMarginReceiptViewModel()
    @Published public var liquidationPrice: dydxAdjustMarginLiquidationPriceViewModel? = dydxAdjustMarginLiquidationPriceViewModel()
    @Published public var inlineAlert: InlineAlertViewModel?
    @Published public var buttonReceipt: dydxAdjustMarginReceiptViewModel? = dydxAdjustMarginReceiptViewModel()
    @Published public var ctaButton: dydxAdjustMarginCtaButtonViewModel? = dydxAdjustMarginCtaButtonViewModel()
    @Published public var shouldDisplayCrossFirst: Bool = true

    public init() {
        super.init()
        amountReceipt?.padding = EdgeInsets(top: 80, leading: 16, bottom: 16, trailing: 16)
        buttonReceipt?.padding = EdgeInsets(top: 16, leading: 16, bottom: 64, trailing: 16)
    }

    public static var previewValue: dydxAdjustMarginInputViewModel {
        let vm = dydxAdjustMarginInputViewModel()
        vm.marginPercentage = .previewValue
        vm.marginDirection = .previewValue
        vm.amount = .init()
        vm.amountReceipt = .previewValue
        vm.liquidationPrice = .previewValue
        vm.buttonReceipt = .previewValue
        vm.ctaButton = .previewValue
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let view = VStack(alignment: .leading, spacing: 0) {
                ScrollView(.vertical) {
                    VStack(alignment: .leading, spacing: 20) {
                        self.createHeader(parentStyle: style)

                        self.marginDirection?.createView(parentStyle: style)

                        self.marginPercentage?.createView(parentStyle: style)

                        ZStack(alignment: .top) {
                            self.amountReceipt?.createView(parentStyle: style)
                            self.amount?.createView(parentStyle: style)
                                .makeInput()
                                .frame(height: 64)
                        }

                        self.liquidationPrice?.createView(parentStyle: style)
                        self.inlineAlert?.createView(parentStyle: style)

                        Spacer()
                    }
                }
                .keyboardObserving()

                Spacer()

                ZStack(alignment: .bottom) {
                    self.buttonReceipt?.createView(parentStyle: style)

                    self.ctaButton?.createView(parentStyle: style)
                }
                .fixedSize(horizontal: false, vertical: true)

            }
                .padding(.horizontal)
                .padding(.bottom, max((self.safeAreaInsets?.bottom ?? 0), 16))
                .themeColor(background: .layer3)
                .makeSheet()
                .onTapGesture {
                    PlatformView.hideKeyboard()
                }

            return AnyView(view.ignoresSafeArea(edges: [.bottom]))
        }
    }

    private func createHeader(parentStyle: ThemeStyle) -> some View {
        HStack(spacing: 12) {
            if let marketIconUrlString = self.sharedMarketViewModel?.logoUrl {
                let placeholderText = self.sharedMarketViewModel?.assetName?.prefix(1).uppercased()
                PlatformIconViewModel(type: .init(url: marketIconUrlString, placeholderText: placeholderText))
                    .createView()
            }
            Text(DataLocalizer.localize(path: "APP.TRADE.ADJUST_ISOLATED_MARGIN"))
                .themeColor(foreground: .textPrimary)
                .leftAligned()
                .themeFont(fontType: .plus, fontSize: .largest)

        }
        .padding(.top, 40)
    }
}

#if DEBUG
struct dydxAdjustMarginInputView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxAdjustMarginInputViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxAdjustMarginInputView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxAdjustMarginInputViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
