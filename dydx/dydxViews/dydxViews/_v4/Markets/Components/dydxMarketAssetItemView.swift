//
//  dydxMarketAssetItemView.swift
//  dydxViews
//
//  Created by Rui Huang on 9/29/22.
//  Copyright © 2022 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities
import PlatformParticles
import DGCharts

// TODO: Add swipe gestures to lazyvstack :/ https://stackoverflow.com/questions/64103113/deleting-rows-inside-lazyvstack-and-foreach-in-swiftui

open class dydxMarketAssetItemViewModel: PlatformViewModel {
    @Published public var sharedMarketViewModel: SharedMarketViewModel? = SharedMarketViewModel()
    @Published public var favoriteViewModel: dydxUserFavoriteViewModel? = dydxUserFavoriteViewModel()
    @Published public var isFavorited: Bool = false
    @Published public var onTap: (() -> Void)?
    @Published public var onFavoriteTap: (() -> Void)?
    @Published public var chartViewModel: dydxChartViewModel?
    @Published public var gradientType: GradientType = .plus

    public init() { }

    public static var previewValue: dydxMarketAssetItemViewModel {
        let vm = dydxMarketAssetItemViewModel()
        vm.sharedMarketViewModel = SharedMarketViewModel.previewValue
        vm.favoriteViewModel = .previewValue
        vm.chartViewModel = dydxChartViewModel(chartView: LineChartView())
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            var leftCellSwipeAccessory: CellSwipeAccessory?
            if let favoriteView = self.favoriteViewModel?.createView(parentStyle: style).tint(ThemeColor.SemanticColor.layer2.color) {
                leftCellSwipeAccessory = CellSwipeAccessory(accessoryView: AnyView(favoriteView), action: self.onFavoriteTap)
            }

            return AnyView(
                self.createContent(parentStyle: style)
                        .onTapGesture {
                            self.onTap?()
                        }
                    .swipeActions(leftCellSwipeAccessory: leftCellSwipeAccessory,
                                  rightCellSwipeAccessory: nil)
            )
        }
    }

    private func createContent(parentStyle: ThemeStyle) -> some View {
        ZStack {
            let icon = PlatformIconViewModel(type: .url(url: sharedMarketViewModel?.logoUrl),
                                             clip: .defaultCircle,
                                             size: CGSize(width: 40, height: 40))
                .createView(parentStyle: parentStyle)
                .wrappedViewModel

            let main = createMain(parentStyle: parentStyle)

            let trailing = createTrailing(parentStyle: parentStyle)

            PlatformTableViewCellViewModel(logo: icon,
                                           main: main.wrappedViewModel,
                                           trailing: trailing.wrappedViewModel)
                .createView(parentStyle: parentStyle)
                .frame(height: 64)
                .themeGradient(background: .layer3, gradientType: gradientType)
                .cornerRadius(16)

            if isFavorited {
                PlatformIconViewModel(type: .asset(name: "action_like_small", bundle: Bundle.dydxView),
                                      size: CGSize(width: 12, height: 12))
                    .createView(parentStyle: parentStyle)
                    .position(x: 24, y: 12)
            }
        }
    }

    private func createMain(parentStyle: ThemeStyle) -> some View {
        HStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading) {
                    HStack(spacing: 4) {
                        Text(sharedMarketViewModel?.tokenSymbol ?? "")
                            .themeColor(foreground: .textPrimary)
                            .themeFont(fontType: .plus, fontSize: .medium)
                            .layoutPriority(1)
                    }
                    Text(sharedMarketViewModel?.volume24H ?? "")
                        .themeFont(fontType: .base, fontSize: .small)
                }
                Spacer()
            }
            .frame(width: 90)

           chartViewModel?.createView(parentStyle: parentStyle)
                .frame(width: 72, height: 50)
                .padding(.trailing, -16)
            // don't allow hit testing since chart views have a bunch of gesture config which interfere with parent gestures
                .allowsHitTesting(false)
        }
    }

    private func createTrailing(parentStyle: ThemeStyle) -> some View {
        VStack(alignment: .trailing, spacing: 2) {
            Text(sharedMarketViewModel?.indexPrice ?? "")
                .themeColor(foreground: .textPrimary)
                .themeFont(fontType: .plus, fontSize: .medium)
                .minimumScaleFactor(0.5)
            if let priceChangePercent24H = sharedMarketViewModel?.priceChangePercent24H {
                priceChangePercent24H
                    .createView(parentStyle: parentStyle, styleKey: "asset_list_item_24h_volume")
            }
        }
    }

}

#if DEBUG
struct dydxMarketAssetItemView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxMarketAssetItemViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxMarketAssetItemView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxMarketAssetItemViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
