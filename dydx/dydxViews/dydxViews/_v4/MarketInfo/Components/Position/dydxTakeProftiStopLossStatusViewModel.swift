//
//  dydxTakeProftiStopLossStatusViewModel.swift
//  dydxUI
//
//  Created by Michael Maguire on 4/23/24.
//  Copyright © 2024 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxTakeProftiStopLossStatusViewModel: PlatformViewModel {

    @Published public var action: (() -> Void)?
    @Published public var triggerPrice: String?
    public let triggerSide: TriggerSide

    public init(triggerSide: TriggerSide, triggerPrice: String?) {
        self.triggerSide = triggerSide
        self.triggerPrice = triggerPrice
    }

    public static var previewValue: dydxTakeProftiStopLossStatusViewModel {
        dydxTakeProftiStopLossStatusViewModel(triggerSide: .stopLoss, triggerPrice: "0.000001")
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] _  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let content = HStack {
                TokenTextViewModel(symbol: DataLocalizer.shared?.localize(path: self.triggerSide.titleStringKey, params: nil) ?? "")
                    .createView(parentStyle: parentStyle.themeFont(fontSize: .smallest), styleKey: styleKey)
                Spacer()
                Text(self.triggerPrice ?? DataLocalizer.localize(path: self.triggerSide.placeholderStringKey))
                    .themeFont(fontSize: .large)
                    .themeColor(foreground: self.triggerPrice == nil ? .textTertiary : .textPrimary)
                    .truncationMode(.middle)
                    .fixedSize()
            }

            return PlatformButtonViewModel(content: content.wrappedViewModel, state: .secondary) {[weak self] in
                self?.action?()
            }
            .createView(parentStyle: parentStyle.themeFont(fontSize: .large))
            .wrappedInAnyView()
        }
    }
}

#if DEBUG
struct dydxTakeProftiStopLossStatusViewModel_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxTakeProftiStopLossStatusViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxTakeProftiStopLossStatusViewModel_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxTakeProftiStopLossStatusViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif

extension dydxTakeProftiStopLossStatusViewModel {
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
