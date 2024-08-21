//
//  dydxMarketTradesView.swift
//  dydxViews
//
//  Created by Rui Huang on 10/11/22.
//  Copyright © 2022 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxMarketTradesViewModel: PlatformViewModel {
    public struct TradeItem: Hashable {
        public init(id: String? = nil, time: String? = nil, side: SideTextViewModel? = nil, price: String? = nil, size: String? = nil, sizePercent: Double = 0) {
            self.id = id
            self.time = time
            self.side = side
            self.price = price
            self.size = size
            self.sizePercent = sizePercent
        }

        let id: String?
        let time: String?
        let side: SideTextViewModel?
        let price: String?
        let size: String?
        let sizePercent: Double

        var sideColor: Color {
            switch side?.side {
            case .buy:
                return ThemeSettings.positiveColorLayer.color
            case .sell:
                return ThemeSettings.negativeColorLayer.color
            default:
                return .clear
            }
        }
    }

    @Published public var tradeItems: [TradeItem] = []

    public init() { }

    public static var previewValue: dydxMarketTradesViewModel = {
        let vm = dydxMarketTradesViewModel()
        vm.tradeItems = [
            .init(time: "12:00am", side: SideTextViewModel.previewValue, price: "$12.00", size: "4k"),
            .init(time: "12:00am", side: SideTextViewModel.previewValue, price: "$12.00", size: "4k")
        ]
        return vm
    }()

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            return AnyView(
                GeometryReader { metrics in
                    VStack(alignment: .leading) {
                        HStack(spacing: 0) {
                            Text(DataLocalizer.localize(path: "APP.GENERAL.TIME"))
                                .leftAligned()
                                .frame(width: metrics.size.width * 0.3)
                            Text(DataLocalizer.localize(path: "APP.GENERAL.SIDE"))
                                .leftAligned()
                                .frame(width: metrics.size.width * 0.2)
                            Text(DataLocalizer.localize(path: "APP.GENERAL.PRICE"))
                                .rightAligned()
                                .frame(width: metrics.size.width * 0.3)
                            Text(DataLocalizer.localize(path: "APP.GENERAL.SIZE"))
                                .rightAligned()
                                .frame(width: metrics.size.width * 0.2)
                        }
                        .themeFont(fontSize: .smaller)
                        .themeColor(foreground: .textTertiary)

                        ScrollView(showsIndicators: false) {
                            LazyVStack(alignment: .leading, spacing: 2) {
                                DividerModel().createView(parentStyle: style)

                                ForEach(self.tradeItems, id: \.id) { item in
                                    ZStack(alignment: .center) {
                                        GeometryReader { metrics in
                                            Rectangle()
                                                .fill(item.sideColor.opacity(0.2))
                                                .leftAligned()
                                                .frame(width: metrics.size.width * item.sizePercent)

                                        }
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 20)

                                        HStack(spacing: 0) {
                                            Text(item.time ?? "")
                                                .leftAligned()
                                                .frame(width: metrics.size.width * 0.3)
                                                .themeFont(fontSize: .smaller)

                                            item.side?
                                                .createView(parentStyle: style.themeFont(fontSize: .smaller))
                                                .leftAligned()
                                                .frame(width: metrics.size.width * 0.2)

                                            Text(item.price ?? "")
                                                .rightAligned()
                                                .frame(width: metrics.size.width * 0.3)
                                                .themeColor(foreground: .textPrimary)
                                                .themeFont(fontType: .number, fontSize: .smaller)
                                                .minimumScaleFactor(0.5)

                                            Text(item.size ?? "")
                                                .rightAligned()
                                                .frame(width: metrics.size.width * 0.2)
                                                .themeColor(foreground: .textPrimary)
                                                .themeFont(fontType: .number, fontSize: .smaller)
                                                .minimumScaleFactor(0.5)
                                        }
                                        .lineLimit(1)
                                    }
                                    .frame(height: 34)

                                    DividerModel().createView(parentStyle: style)
                                }
                            }
                        }
                    }
                }
                .clipped()
                .padding(.top, 8)
                .padding(.horizontal, 8)
                .animation(.default, value: self.tradeItems)
            )
        }
    }
}

#if DEBUG
struct dydxMarketTradesView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxMarketTradesViewModel.previewValue
            .createView()
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxMarketTradesView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxMarketTradesViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
