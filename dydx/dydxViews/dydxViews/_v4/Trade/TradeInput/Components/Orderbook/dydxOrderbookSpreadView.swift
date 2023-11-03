//
//  dydxOrderbookSpreadView.swift
//  dydxViews
//
//  Created by John Huang on 1/4/23.
//

import PlatformUI
import SwiftUI
import Utilities
import dydxFormatter

public class dydxOrderbookSpreadViewModel: PlatformValueOutputViewModel {
    @Published public var percent: Double?

    public static var previewValue: dydxOrderbookSpreadViewModel {
        let vm = dydxOrderbookSpreadViewModel()
        vm.percent = 0.045
        return vm
    }

    public init() {
    }

    override public func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] _ in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let text = dydxFormatter.shared.percent(number: self.percent, digits: 2) ?? ""
            return AnyView(
                HStack(alignment: .center) {
                    Spacer()
                    Text(DataLocalizer.localize(path: "APP.TRADE.ORDERBOOK_SPREAD"))
                        .themeColor(foreground: .textTertiary)
                        .themeFont(fontType: .text, fontSize: .smaller)
                    Text(text)
                        .themeFont(fontType: .number, fontSize: .smaller)
                        .themeColor(foreground: .textPrimary)
                }
                // this custom padding helps to align the edge of the spread value with the order book. It is a band-aid fix.
                .padding(.trailing, 8)
            )
        }
    }
}

#if DEBUG
struct dydxOrderbookSpreadViewModel_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxOrderbookSpreadViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxOrderbookSpreadViewModel_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxOrderbookSpreadViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
