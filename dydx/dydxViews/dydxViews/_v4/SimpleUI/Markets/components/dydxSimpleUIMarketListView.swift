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

    private let dummyNoMarket = dydxSimpleUIMarketViewModel(displayType: .market, positionToggleType: .pnl, marketId: "_dummy_no_market", assetName: "", iconUrl: nil, price: nil, change: nil, unrealizedPNLAmount: nil, marginValue: nil, marginUsage: .previewValue, sideText: SideTextViewModel.previewValue, leverage: nil, volumn: nil, positionTotal: nil, positionSize: nil, marketCaps: nil, isLaunched: true, isFavorite: false, onMarketSelected: nil, onCancelAction: nil, onFavoriteTapped: nil)

    private let loadingList: [dydxSimpleUIMarketViewModel] = {
        var list = [dydxSimpleUIMarketViewModel]()
        for i in 0..<10 {
            let item = dydxSimpleUIMarketViewModel(displayType: .market, positionToggleType: .pnl, marketId: "_dummy_loading_\(i)", assetName: "ETH", iconUrl: nil, price: "$100.00", change: .previewValue, unrealizedPNLAmount: .previewValue, marginValue: nil, marginUsage: .previewValue, sideText: SideTextViewModel.previewValue, leverage: nil, volumn: 20000000, positionTotal: nil, positionSize: nil, isLoading: true, marketCaps: 10000000, isLaunched: true, isFavorite: false, onMarketSelected: nil, onCancelAction: nil, onFavoriteTapped: nil)
            list.append(item)
        }
        return list
    }()

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            // Need to insert "No Market" into ForEach for better performance
            let markets: [dydxSimpleUIMarketViewModel]
            if self.markets == nil {
                markets = loadingList
            } else if self.markets?.count == 0 {
                markets = [dummyNoMarket]
            } else {
                markets = self.markets ?? []
            }

            let view = ForEach(markets, id: \.marketId) { market in
                if market.marketId == "_dummy_no_market" {
                    PlaceholderViewModel(text: DataLocalizer.localize(path: "APP.GENERAL.NO_MARKET"))
                        .createView(parentStyle: style)
                } else {
                    market.createView(parentStyle: style)
                }
            }

            return AnyView(view)
        }
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
