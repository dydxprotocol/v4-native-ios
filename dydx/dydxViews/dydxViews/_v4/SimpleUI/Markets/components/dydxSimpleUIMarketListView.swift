//
//  dydxSimpleUIMarketListView.swift
//  dydxUI
//
//  Created by Rui Huang on 18/12/2024.
//  Copyright © 2024 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxSimpleUIMarketListViewModel: PlatformViewModel {
    @Published public var markets: [dydxSimpleUIMarketViewModel]?

    public init() { }

    public static var previewValue: dydxSimpleUIMarketListViewModel {
        let vm = dydxSimpleUIMarketListViewModel()
        vm.markets = [
            dydxSimpleUIMarketViewModel.previewValue,
            dydxSimpleUIMarketViewModel.previewValue
        ]
        return vm
    }

    private let dummyNoMarket = dydxSimpleUIMarketViewModel(marketId: "_dummy_no_market", assetName: "", iconUrl: nil, price: nil, change: nil, sideText: SideTextViewModel.previewValue, leverage: nil, volumn: nil, positionTotal: nil, positionSize: nil, onMarketSelected: nil)

    private let dummyLoading = dydxSimpleUIMarketViewModel(marketId: "_dummy_loading", assetName: "", iconUrl: nil, price: nil, change: nil, sideText: SideTextViewModel.previewValue, leverage: nil, volumn: nil, positionTotal: nil, positionSize: nil, onMarketSelected: nil)

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            // Need to insert "No Market" into ForEach for better performance
            let markets: [dydxSimpleUIMarketViewModel]
            if self.markets == nil {
                markets = [dummyLoading]
            } else if self.markets?.count == 0 {
                markets = [dummyNoMarket]
            } else {
                markets = self.markets ?? []
            }

            let view = ForEach(markets, id: \.marketId) { market in
                if market.marketId == "_dummy_loading" {
                    HStack {
                        Spacer()
                        ProgressView()
                            .progressViewStyle(.circular)
                            .tint(ThemeColor.SemanticColor.textSecondary.color)
                        Spacer()
                    }
                } else if market.marketId == "_dummy_no_market" {
                    PlaceholderViewModel(text: DataLocalizer.localize(path: "APP.GENERAL.NO_MARKET"))
                        .createView(parentStyle: style)
                } else {
                    market.createView(parentStyle: style)
                }
            }

            return AnyView(view)
        }
    }

    private func createHeader(text: String) -> some View {
        VStack(spacing: 0) {
            Text(text)
                .themeFont(fontType: .plus)
                .themeColor(foreground: .textPrimary)
                .leftAligned()
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
        }
        .themeColor(background: .layer2)
    }
}

#if DEBUG
struct dydxSimpleUIMarketListView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxSimpleUIMarketListViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxSimpleUIMarketListView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxSimpleUIMarketListViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
