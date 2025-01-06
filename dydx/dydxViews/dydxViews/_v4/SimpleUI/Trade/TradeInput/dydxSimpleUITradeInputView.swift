//
//  dydxSimpleUITradeInputView.swift
//  dydxUI
//
//  Created by Rui Huang on 27/12/2024.
//  Copyright © 2024 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxSimpleUITradeInputViewModel: PlatformViewModel {
    public enum DisplayState {
        case tip, full
    }

    public enum TipState {
        case buySell, draft
    }

    @Published public var displayState: DisplayState = .tip
    @Published public var tipState: TipState = .buySell

    @Published public var tipBuySellViewModel: dydxTradeSheetTipBuySellViewModel? = dydxTradeSheetTipBuySellViewModel()
    @Published public var tipDraftViewModel: dydxTradeSheetTipDraftViewModel? = dydxTradeSheetTipDraftViewModel()

    @Published public var sideViewModel: dydxTradeInputSideViewModel? = dydxTradeInputSideViewModel()
    @Published public var ctaButtonViewModel: dydxTradeInputCtaButtonViewModel? = dydxTradeInputCtaButtonViewModel()
    @Published public var sizeViewModel: dydxSimpleUITradeInputSizeViewModel? = dydxSimpleUITradeInputSizeViewModel()

    @Published public var buyingPowerViewModel = dydxReceiptBuyingPowerViewModel()
    @Published public var validationErrorViewModel: ValidationErrorViewModel? = ValidationErrorViewModel()

    @Published public var onScrollViewCreated: ((UIScrollView) -> Void)?

    public init() { }

    public static var previewValue: dydxSimpleUITradeInputViewModel {
        let vm = dydxSimpleUITradeInputViewModel()
        vm.tipBuySellViewModel = .previewValue
        vm.tipDraftViewModel = .previewValue
        vm.sideViewModel = .previewValue
        vm.ctaButtonViewModel = .previewValue
        vm.sizeViewModel = .previewValue
        vm.buyingPowerViewModel = .previewValue
        vm.displayState = .full
        vm.validationErrorViewModel = .previewValue
       return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let bottomPadding = max((self.safeAreaInsets?.bottom ?? 0), 16)

            let view =
                VStack(spacing: 16) {
                    if case(.tip) = self.displayState {
                        self.createSwipeUpView(parentStyle: style)
                        Spacer()
                    } else {
                        VStack {
                            ScrollView(showsIndicators: false) {
                                VStack {
                                    self.sideViewModel?
                                        .createView(parentStyle: parentStyle)
                                        .padding([.top], 34)
                                        .padding([.bottom], 36)

                                    self.sizeViewModel?
                                        .createView(parentStyle: parentStyle)

                                    self.validationErrorViewModel?
                                        .createView(parentStyle: parentStyle)
                                }
                                .introspectScrollView { [weak self] scrollView in
                                    self?.onScrollViewCreated?(scrollView)
                                }
                            }

                            Spacer()

                            VStack {
                                self.buyingPowerViewModel.createView(parentStyle: style)
                                    .padding(.horizontal, 8)

                                self.ctaButtonViewModel?.createView(parentStyle: style)
                            }
                            .keyboardObserving(offset: -bottomPadding + 16, mode: .yOffset)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, bottomPadding)
                .themeColor(background: .layer3)
               // .keyboardAccessory(background: .layer3, parentStyle: parentStyle)
                .makeSheet()

            // make it visible under the tabbar
            return AnyView(view.ignoresSafeArea(edges: [.bottom]))
        }
    }

    private func createSwipeUpView(parentStyle: ThemeStyle) -> some View {
        Group {
            switch tipState {
            case .buySell:
                tipBuySellViewModel?
                    .createView(parentStyle: parentStyle)
                    .padding([.top], 34)
                    .padding([.bottom], 10)
            case .draft:
                tipDraftViewModel?
                    .createView(parentStyle: parentStyle)
                    .padding([.top], 34)
                    .padding([.bottom], 10)
                    .padding([.leading, .trailing])
            }
        }
    }
}

#if DEBUG
struct dydxSimpleUITradeInputView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxSimpleUITradeInputViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxSimpleUITradeInputView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxSimpleUITradeInputViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
