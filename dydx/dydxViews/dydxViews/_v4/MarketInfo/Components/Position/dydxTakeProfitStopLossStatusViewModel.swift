//
//  dydxTakeProfitStopLossStatusViewModel.swift
//  dydxUI
//
//  Created by Michael Maguire on 4/23/24.
//  Copyright © 2024 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxTakeProfitStopLossStatusViewModel: PlatformViewModel {

    @Published public var triggerPriceText: String?
    @Published public var limitPrice: String?
    @Published public var amount: String?
    @Published public var action: (() -> Void)?
    public let triggerSide: TriggerSide

    public init(triggerSide: TriggerSide, triggerPriceText: String? = nil, limitPrice: String? = nil, amount: String? = nil, action: (() -> Void)? = nil) {
        self.triggerSide = triggerSide
        self.triggerPriceText = triggerPriceText
        self.limitPrice = limitPrice
        self.amount = amount
        self.action = action

    }

    public static var previewValue: dydxTakeProfitStopLossStatusViewModel {
        dydxTakeProfitStopLossStatusViewModel(triggerSide: .stopLoss, triggerPriceText: "0.000001")
    }

    private func createTitleValueRow(titleStringKey: String, value: String?) -> AnyView? {
        guard let value = value else { return nil }
        return HStack(spacing: 0) {
            Text(DataLocalizer.shared?.localize(path: titleStringKey, params: nil) ?? "")
                .themeFont(fontType: .base, fontSize: .smaller)
                .themeColor(foreground: .textTertiary)
                .fixedSize()
            Spacer(minLength: 10)
            Text(value)
                .themeFont(fontType: .base, fontSize: .smaller)
                .themeColor(foreground: .textSecondary)
                .fixedSize()
        }
        .wrappedInAnyView()
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] _  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let content = VStack(spacing: 0) {
                Spacer(minLength: 0)
                VStack(spacing: 14) {
                    HStack(spacing: 0) {
                        TokenTextViewModel(symbol: DataLocalizer.shared?.localize(path: self.triggerSide.titleStringKey, params: nil) ?? "")
                            .createView(parentStyle: parentStyle.themeFont(fontSize: .smallest), styleKey: styleKey)
                            .fixedSize()
                        Spacer(minLength: 10)
                        Text(self.triggerPriceText ?? DataLocalizer.localize(path: self.triggerSide.placeholderStringKey))
                            .themeFont(fontType: .base, fontSize: .large)
                            .themeColor(foreground: self.triggerPriceText == nil ? .textTertiary : .textPrimary)
                            .truncationMode(.middle)
                            .minimumScaleFactor(0.5)
                            .lineLimit(1)
                    }
                    if self.limitPrice != nil || self.amount != nil {
                        VStack(spacing: 8) {
                            Divider()
                                .overlay(ThemeColor.SemanticColor.textTertiary.color)
                                .padding(.horizontal, -100) // this padding counteracts the button horizontal padding
                            VStack(spacing: 4) {
                                self.createTitleValueRow(titleStringKey: "APP.TRADE.LIMIT_ORDER_SHORT", value: self.limitPrice)
                                self.createTitleValueRow(titleStringKey: "APP.GENERAL.AMOUNT", value: self.amount)
                            }
                            .padding(.bottom, -6) // this padding counteracts the button bottom padding
                        }
                    }

                }
                Spacer(minLength: 0)
            }
                .padding(.horizontal, -4) // this padding counteracts some of the button horizontal padding, to be updated

            return PlatformButtonViewModel(content: content.wrappedViewModel, state: .secondary) {[weak self] in
                self?.action?()
            }
            .createView(parentStyle: parentStyle.themeFont(fontSize: .large))
            .wrappedInAnyView()
        }
    }
}

#if DEBUG
struct dydxTakeProfitStopLossStatusViewModel_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxTakeProfitStopLossStatusViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxTakeProfitStopLossStatusViewModel_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxTakeProfitStopLossStatusViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif

extension dydxTakeProfitStopLossStatusViewModel {
    public enum TriggerSide {
        case takeProfit, stopLoss

        var titleStringKey: String {
            switch self {
            case .takeProfit:
                return "TP"
            case .stopLoss:
                return "SL"
            }
        }

        var placeholderStringKey: String {
            switch self {
            case .takeProfit:
                return "APP.TRADE.ADD_TAKE_PROFIT"
            case .stopLoss:
                return "APP.TRADE.ADD_STOP_LOSS"
            }
        }
    }
}
