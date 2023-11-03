//
//  dydxTradeSheetTipBuySellView.swift
//  dydxUI
//
//  Created by Rui Huang on 9/26/23.
//  Copyright © 2023 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxTradeSheetTipBuySellViewModel: PlatformViewModel {
    public struct Item: Identifiable {
        public let id = UUID()

        public let option: InputSelectOption
        public let color: ThemeColor.SemanticColor

        public init(option: InputSelectOption, color: ThemeColor.SemanticColor) {
            self.option = option
            self.color = color
        }
    }

    @Published public var items = [Item]()
    @Published public var tapAction: ((InputSelectOption) -> Void)?

    public init() { }

    public static var previewValue: dydxTradeSheetTipBuySellViewModel {
        let vm = dydxTradeSheetTipBuySellViewModel()
        vm.items.append(Item(option: InputSelectOption(value: "BUY", string: "APP.TRADE.BUY"),
                               color: .colorGreen))
        vm.items.append(Item(option: InputSelectOption(value: "SELL", string: "APP.TRADE.SELL"),
                               color: .colorRed))
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            return AnyView(
                HStack {
                    ForEach(self.items) { item in
                        let text = item.option.string
                        let buttonModel = BuySellButtonModel(text: text, color: item.color, tapAction: { [weak self] in
                            self?.tapAction?(item.option)
                        })
                        buttonModel
                            .createView(parentStyle: style)
                    }
                }
            )
        }
    }
}

#if DEBUG
struct dydxTradeSheetTipBuySellView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxTradeSheetTipBuySellViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxTradeSheetTipBuySellView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxTradeSheetTipBuySellViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
