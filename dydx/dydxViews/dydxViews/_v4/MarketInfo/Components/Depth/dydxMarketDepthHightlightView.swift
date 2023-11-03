//
//  dydxMarketDepthHightlightView.swift
//  dydxViews
//
//  Created by Rui Huang on 1/3/23.
//  Copyright © 2023 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxMarketDepthHightlightViewModel: PlatformViewModel {
    public enum State {
        case bids
        case asks
    }
    @Published public var price: String?
    @Published public var size: String?
    @Published public var cost: String?
    @Published public var impact: String?
    @Published public var state: State = .bids
    @Published public var token: TokenTextViewModel?

    public let width: CGFloat = 240
    public let height: CGFloat = 128

    public init() { }

    public static var previewValue: dydxMarketDepthHightlightViewModel {
        let vm = dydxMarketDepthHightlightViewModel()
        vm.price = "$0.11"
        vm.size = "$0.11"
        vm.cost = "$0.11"
        vm.impact = "$0.11"
        vm.token = .previewValue
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            return AnyView(
                HStack {
                    if case .bids = self.state {
                        Rectangle()
                            .fill(ThemeSettings.positiveColor.color )
                            .frame(width: 8)
                    }

                    VStack(spacing: 12) {
                        HStack {
                            Text(DataLocalizer.localize(path: "APP.GENERAL.PRICE"))
                                .themeColor(foreground: .textTertiary)
                            Spacer()
                            Text(self.price ?? "")
                        }
                        HStack {
                            Text(DataLocalizer.localize(path: "APP.TRADE.TOTAL_SIZE"))
                                .themeColor(foreground: .textTertiary)
                            self.token?.createView(parentStyle: style.themeFont(fontSize: .smallest))
                            Spacer()
                            Text(self.size ?? "")
                        }
                        HStack {
                            Text(DataLocalizer.localize(path: "APP.TRADE.TOTAL_COST"))
                                .themeColor(foreground: .textTertiary)
                            Spacer()
                            Text(self.cost ?? "")
                        }
                        HStack {
                            Text(DataLocalizer.localize(path: "APP.TRADE.PRICE_IMPACT"))
                                .themeColor(foreground: .textTertiary)
                            Spacer()
                            Text(self.impact ?? "")
                        }
                    }
                    .themeFont(fontSize: .small)
                    .padding(8)

                    if case .asks = self.state {
                        Rectangle()
                            .fill(ThemeSettings.negativeColor.color)
                            .frame(width: 8)
                    }
                }
                .themeColor(background: .layer4)
                .frame(width: self.width, height: self.height)
                .cornerRadius(8)
            )
        }
    }
}

#if DEBUG
struct dydxMarketDepthHightlightView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxMarketDepthHightlightViewModel.previewValue
            .createView()
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxMarketDepthHightlightView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxMarketDepthHightlightViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
