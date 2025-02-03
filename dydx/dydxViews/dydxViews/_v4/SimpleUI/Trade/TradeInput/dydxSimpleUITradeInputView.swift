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
    @Published public var header: dydxSimpleUITradeInputHeaderViewModel?

    @Published public var ctaButtonViewModel: dydxSimpleUITradeInputCtaButtonView? = dydxSimpleUITradeInputCtaButtonView()
    @Published public var sizeViewModel: dydxSimpleUITradeInputSizeViewModel? = dydxSimpleUITradeInputSizeViewModel()

    @Published public var positionViewModel: dydxSimpleUITradeInputPositionViewModel? =  dydxSimpleUITradeInputPositionViewModel()
    @Published public var buyingPowerViewModel: dydxSimpleUIBuyingPowerViewModel? =  dydxSimpleUIBuyingPowerViewModel()
    @Published public var marginUsageViewModel: dydxSimpleUIMarginUsageViewModel? =  dydxSimpleUIMarginUsageViewModel()
    @Published public var feesViewModel: dydxSimpleUIFeesViewModel? = dydxSimpleUIFeesViewModel()

    @Published public var validationErrorViewModel: ValidationErrorViewModel? = ValidationErrorViewModel()

    @Published public var onScrollViewCreated: ((UIScrollView) -> Void)?

    public init() { }

    public static var previewValue: dydxSimpleUITradeInputViewModel {
        let vm = dydxSimpleUITradeInputViewModel()
        vm.header = .previewValue
        vm.ctaButtonViewModel = .previewValue
        vm.sizeViewModel = .previewValue
        vm.positionViewModel = .previewValue
        vm.buyingPowerViewModel = .previewValue
        vm.marginUsageViewModel = .previewValue
        vm.feesViewModel = .previewValue
        vm.validationErrorViewModel = .previewValue
       return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let bottomPadding = max((self.safeAreaInsets?.bottom ?? 0), 16)

            let view = VStack(spacing: 16) {
                self.header?.createView(parentStyle: style)

                VStack {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 16) {
                            VStack(spacing: 16) {
                                Group {
                                    self.positionViewModel?.createView(parentStyle: style)
                                    self.buyingPowerViewModel?.createView(parentStyle: style)
                                }
                                    .padding(.horizontal, 8)

                                self.sizeViewModel?
                                    .createView(parentStyle: parentStyle)
                            }
                            .padding(.top, 34)

                            self.validationErrorViewModel?
                                .createView(parentStyle: parentStyle)
                                .animation(.default)
                        }
                        .introspectScrollView { [weak self] scrollView in
                            self?.onScrollViewCreated?(scrollView)
                        }
                    }

                    Spacer()

                    VStack(spacing: 21) {
                        HStack {
                            self.marginUsageViewModel?.createView(parentStyle: style)
                            Spacer()
                            self.feesViewModel?.createView(parentStyle: style)
                        }
                        self.ctaButtonViewModel?.createView(parentStyle: style)
                            .frame(height: 62)
                    }
                    .keyboardObserving(offset: -bottomPadding + 16, mode: .yOffset)
                }
            }
                .padding(.horizontal, 16)
                .padding(.top, 32)
                .padding(.bottom, bottomPadding)
                .themeColor(background: .layer1)

            // make it visible under the tabbar
            return AnyView(view.ignoresSafeArea(edges: [.bottom]))
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
