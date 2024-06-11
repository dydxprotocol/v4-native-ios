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
import KeyboardObserving

public class dydxAdjustMarginInputViewModel: PlatformViewModel {
    @Published public var sharedMarketViewModel: SharedMarketViewModel? = SharedMarketViewModel()
    @Published public var marginDirection: dydxAdjustMarginDirectionViewModel? = dydxAdjustMarginDirectionViewModel()
    @Published public var marginPercentage: dydxAdjustMarginPercentageViewModel? = dydxAdjustMarginPercentageViewModel()
    @Published public var amount: dydxAdjustMarginAmountViewModel? = dydxAdjustMarginAmountViewModel()
    @Published public var subaccountReceipt: dydxAdjustMarginSubaccountReceiptViewModel? = dydxAdjustMarginSubaccountReceiptViewModel()
    @Published public var liquidationPrice: dydxAdjustMarginLiquidationPriceViewModel? = dydxAdjustMarginLiquidationPriceViewModel()
    @Published public var positionReceipt: dydxAdjustMarginPositionReceiptViewModel? = dydxAdjustMarginPositionReceiptViewModel()
    @Published public var ctaButton: dydxAdjustMarginCtaButtonViewModel? = dydxAdjustMarginCtaButtonViewModel()

    public init() { }

    public static var previewValue: dydxAdjustMarginInputViewModel {
        let vm = dydxAdjustMarginInputViewModel()
        vm.marginPercentage = .previewValue
        vm.marginDirection = .previewValue
        vm.amount = .previewValue
        vm.subaccountReceipt = .previewValue
        vm.liquidationPrice = .previewValue
        vm.positionReceipt = .previewValue
        vm.ctaButton = .previewValue
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let view = VStack(alignment: .leading, spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        self.createHeader(parentStyle: style)

                        self.marginDirection?.createView(parentStyle: style)

                        self.marginPercentage?.createView(parentStyle: style)

                        ZStack {
                            self.subaccountReceipt?.createView(parentStyle: style)
                                .padding(.top, 44)
                            self.amount?.createView(parentStyle: style)
                                .frame(height: 64)
                                .topAligned()
                        }
                        .frame(height: 140)

                        self.liquidationPrice?.createView(parentStyle: style)
                    }
                }
                .keyboardObserving()

                Spacer(minLength: 20)

                VStack {

                    self.positionReceipt?.createView(parentStyle: style)

                    self.ctaButton?.createView(parentStyle: style)
                        .padding(.top, -24)
                }
                .frame(height: 140)

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
                PlatformIconViewModel(type: .url(url: marketIconUrlString, placeholderContent: nil),
                                      size: CGSize(width: 32, height: 32))
                .createView(parentStyle: parentStyle)
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
