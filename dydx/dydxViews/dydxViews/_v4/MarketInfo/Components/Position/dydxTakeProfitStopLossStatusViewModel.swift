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
        return HStack(spacing: 8) {
            Text(DataLocalizer.shared?.localize(path: titleStringKey, params: nil) ?? "")
                .multilineTextAlignment(.leading)
                .themeFont(fontSize: .small)
                .themeColor(foreground: .textTertiary)
                .frame(width: 60)

            Spacer()

            Text(value)
                .themeFont(fontType: .base, fontSize: .small)
                .themeColor(foreground: .textPrimary)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
        }
        .wrappedInAnyView()
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let content = VStack(spacing: 8) {
                HStack(spacing: 8) {
                    Text(DataLocalizer.shared?.localize(path: self.triggerSide.titleStringKey, params: nil) ?? "")
                        .themeFont(fontSize: .small)
                        .themeColor(foreground: .textTertiary)
                        .frame(width: 60)

                    Spacer()

                    Text(self.triggerPriceText ?? "")
                        .themeFont(fontType: .base, fontSize: .large)
                        .themeColor(foreground: .textPrimary)
                        .truncationMode(.middle)
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                }
                if self.limitPrice != nil || self.amount != nil {
                    DividerModel().createView(parentStyle: style)
                        .padding(.horizontal, -8)

                    VStack(spacing: 4) {
                        self.createTitleValueRow(titleStringKey: "APP.TRADE.LIMIT_ORDER_SHORT", value: self.limitPrice)
                        self.createTitleValueRow(titleStringKey: "APP.GENERAL.AMOUNT", value: self.amount)
                    }
                }
            }
                .padding(8)
                .themeColor(background: .layer3)
                .cornerRadius(10, corners: .allCorners)

            return PlatformButtonViewModel(content: content.wrappedViewModel, type: .iconType) {[weak self] in
                self?.action?()
            }
            .createView(parentStyle: style)
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
                return "APP.TRADE.TAKE_PROFIT"
            case .stopLoss:
                return "APP.TRADE.STOP_LOSS"
            }
        }
    }
}
