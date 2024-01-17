//
//  dydxReceiptBuyingPowerView.swift
//  dydxViews
//
//  Created by John Huang on 1/4/23.
//

import PlatformUI
import SwiftUI
import Utilities

public class dydxReceiptQuoteBalanceViewModel: PlatformViewModel {
    public struct QuoteBalanceChange: Identifiable {
        let symbol: String
        let change: AmountChangeModel

        public var id: String {
            symbol
        }

        public init(symbol: String, change: AmountChangeModel) {
            self.symbol = symbol
            self.change = change
        }
    }

    @Published public var quoteBalanceChange: QuoteBalanceChange?

    public init() {}

    public static var previewValue: dydxReceiptQuoteBalanceViewModel = {
        let vm = dydxReceiptQuoteBalanceViewModel()
        vm.quoteBalanceChange = QuoteBalanceChange(symbol: "", change: .previewValue)
        return vm
    }()

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            return AnyView(
                HStack {
                    Text("Available Fund")
                        .themeFont(fontSize: .small)
                        .themeColor(foreground: .textTertiary)
                        .lineLimit(1)
                    Spacer()
                    if let quoteBalanceChange = self.quoteBalanceChange?.change {
                        quoteBalanceChange.createView(parentStyle: style)
                            .lineLimit(1)
                    } else {
                        dydxReceiptEmptyView.emptyValue
                    }
                }
            )
        }
    }
}

#if DEBUG
struct dydxReceiptQuoteBalanceView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxReceiptQuoteBalanceViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxReceiptQuoteBalanceView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxReceiptQuoteBalanceViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
