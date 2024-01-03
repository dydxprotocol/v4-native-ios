//
//  dydxTradeInputView.swift
//  dydxViews
//
//  Created by Rui Huang on 1/4/23.
//

import PlatformUI
import SwiftUI
import Utilities

public class dydxTradeInputViewModel: PlatformViewModel {
    public enum DisplayState {
        case tip, full
    }

    public enum TipState {
        case buySell, draft
    }

    @Published public var displayState: DisplayState = .tip
    @Published public var tipState: TipState = .buySell
    @Published public var isOrderbookCollapsed: Bool = false
    @Published public var isShowingValidation: Bool = false
    @Published public var orderTypeViewModel: dydxTradeInputOrderTypeViewModel? = dydxTradeInputOrderTypeViewModel()
    @Published public var sideViewModel: dydxTradeInputSideViewModel? = dydxTradeInputSideViewModel()
    @Published public var orderbookManagerViewModel: dydxOrderbookManagerViewModel? = dydxOrderbookManagerViewModel()
    @Published public var editViewModel: dydxTradeInputEditViewModel? = dydxTradeInputEditViewModel()
    @Published public var orderbookViewModel: dydxOrderbookViewModel? = dydxOrderbookViewModel()
    @Published public var ctaButtonViewModel: dydxTradeInputCtaButtonViewModel? = dydxTradeInputCtaButtonViewModel()
    @Published public var validationViewModel: dydxValidationViewModel? = dydxValidationViewModel()
    @Published public var tipBuySellViewModel: dydxTradeSheetTipBuySellViewModel? =  dydxTradeSheetTipBuySellViewModel()
    @Published public var tipDraftViewModel: dydxTradeSheetTipDraftViewModel? =  dydxTradeSheetTipDraftViewModel()

    public override init(bodyBuilder: ((ThemeStyle) -> AnyView)? = nil) {
        super.init(bodyBuilder: bodyBuilder)

        orderbookManagerViewModel?.isOrderbookCollapsedChanged = { [weak self] val in
            withAnimation(.linear(duration: 0.1)) {
                self?.isOrderbookCollapsed = val
            }
        }
    }

    public static var previewValue: dydxTradeInputViewModel {
        let vm = dydxTradeInputViewModel()
        vm.orderTypeViewModel = .previewValue
        vm.editViewModel = .previewValue
        vm.sideViewModel = .previewValue
        vm.orderbookManagerViewModel = .previewValue
        vm.orderbookViewModel = .previewValue
        vm.ctaButtonViewModel = .previewValue
        vm.validationViewModel = .previewValue
        vm.tipBuySellViewModel = .previewValue
        vm.tipDraftViewModel = .previewValue
        return vm
    }

    override public func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let spacing = 16.0
            let fullWidth = UIScreen.main.bounds.width - spacing * 2
            let widthWithoutSpacing = fullWidth - spacing
            let orderbookViewProportion = 0.45
            let editViewWidth = widthWithoutSpacing * (1 - orderbookViewProportion)
            let orderbookWdith = widthWithoutSpacing * orderbookViewProportion

            let view =
                VStack(spacing: 0) {
                    if case(.tip) = self.displayState {
                        self.createSwipeUpView(parentStyle: style)
                    }

                    self.orderTypeViewModel?.createView(parentStyle: style)
                        .frame(height: 64)
                        .padding(.top, 32)
                        .padding(.horizontal, -spacing)

                    HStack(spacing: spacing) {
                        self.orderbookManagerViewModel?.createView(parentStyle: style)
                            .frame(width: orderbookWdith)
                        self.sideViewModel?.createView(parentStyle: style)
                            .frame(width: editViewWidth)
                    }

                    Spacer(minLength: 8)

                    HStack(spacing: spacing) {
                         if !self.isOrderbookCollapsed {
                            self.orderbookViewModel?.createView(parentStyle: style)
                                .frame(width: orderbookWdith + spacing)
                                .padding(.leading, -spacing)
                                .topAligned()
                        }
                        self.editViewModel?.createView(parentStyle: style)
                            .frame(width: self.isOrderbookCollapsed ? fullWidth: editViewWidth)
                    }
                    .frame(minHeight: 0, maxHeight: .infinity)

                    VStack(spacing: -8) {
                        if self.isShowingValidation {
                            VStack {
                                self.validationViewModel?.createView(parentStyle: style)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .themeColor(background: .layer1)
                            .cornerRadius(12, corners: [.topLeft, .topRight])
                        }

                        self.ctaButtonViewModel?.createView(parentStyle: style)
                    }
                }
                .padding(.horizontal, spacing)
                .padding(.bottom, max((self.safeAreaInsets?.bottom ?? 0), 16))
                .themeColor(background: .layer3)
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
struct dydxTradeInputView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxTradeInputViewModel.previewValue
            .createView()
            .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.device)
    }
}

struct dydxTradeInputView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxTradeInputViewModel.previewValue
            .createView()
            .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.device)
    }
}
#endif
