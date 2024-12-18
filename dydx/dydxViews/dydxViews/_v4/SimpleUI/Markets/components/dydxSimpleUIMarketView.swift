//
//  dydxSimpleUIMarketView.swift
//  dydxUI
//
//  Created by Rui Huang on 18/12/2024.
//  Copyright © 2024 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxSimpleUIMarketViewModel: PlatformViewModel {
    public let marketId: String
    public let assetName: String
    public let iconUrl: String?
    public let price: String?
    public let change: SignedAmountViewModel?
    public let sideText: SideTextViewModel
    public let leverage: String?
    public let volumn: Double?
    public let onMarketSelected: (() -> Void)?

    public init(marketId: String,
                assetName: String,
                iconUrl: String?,
                price: String?,
                change: SignedAmountViewModel?,
                sideText: SideTextViewModel,
                leverage: String?,
                volumn: Double?,
                onMarketSelected: (() -> Void)?
    ) {
        self.marketId = marketId
        self.assetName = assetName
        self.iconUrl = iconUrl
        self.price = price
        self.change = change
        self.sideText = sideText
        self.leverage = leverage
        self.volumn = volumn
        self.onMarketSelected = onMarketSelected
    }

    public static var previewValue: dydxSimpleUIMarketViewModel {
        let vm = dydxSimpleUIMarketViewModel(marketId: "ETH-USD",
                                             assetName: "ETH",
                                             iconUrl: "https://assets.coingecko.com/coins/images/1/large/bitcoin.png",
                                             price: "50_000",
                                             change: .previewValue,
                                             sideText: .previewValue,
                                             leverage: "1.34",
                                             volumn: nil,
                                             onMarketSelected: nil)
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let view = Button { [weak self] in
                self?.onMarketSelected?()
            } label: {
                HStack(spacing: 20) {
                   HStack(spacing: 12) {
                       self.createIcon(style: style)
                       self.createNamePosition(style: style)
                   }
                       .leftAligned()

                   self.createPriceChange(style: style)
                       .rightAligned()
               }
               .lineLimit(1)
               .minimumScaleFactor(0.5)
               .padding(.horizontal, 16)
               .padding(.vertical, 12)
            }

            return AnyView(view)
        }
    }

    private func createIcon(style: ThemeStyle) -> some View {
        let placeholderText = { [weak self] in
            if let assetName = self?.assetName {
                return Text(assetName.prefix(1))
                    .frame(width: 32, height: 32)
                    .themeColor(foreground: .textTertiary)
                    .themeColor(background: .layer5)
                    .borderAndClip(style: .circle, borderColor: .layer7, lineWidth: 1)
                    .wrappedInAnyView()
            }
            return AnyView(PlatformView.nilView)
        }
        let iconType = PlatformIconViewModel.IconType.url(url: URL(string: iconUrl ?? ""), placeholderContent: placeholderText)
        return PlatformIconViewModel(type: iconType,
                                     clip: .circle(background: .transparent, spacing: 0),
                                     size: CGSize(width: 32, height: 32))
            .createView(parentStyle: style)
    }

    private func createNamePosition(style: ThemeStyle) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(assetName)
                .themeColor(foreground: .textPrimary)
                .themeFont(fontSize: .medium)

            HStack {
                sideText.createView(parentStyle: style.themeFont(fontSize: .small))
                if let leverage = leverage {
                    Text(leverage)
                        .themeColor(foreground: .textSecondary)
                        .themeFont(fontSize: .small)
                }
            }
        }
    }

    private func createPriceChange(style: ThemeStyle) -> some View {
        VStack(alignment: .trailing, spacing: 4) {
            Text(price ?? "")
                .themeColor(foreground: .textPrimary)
                .themeFont(fontSize: .medium)

            change?.createView(parentStyle: style.themeFont(fontSize: .small))
        }
    }
}

#if DEBUG
struct dydxSimpleUIMarketView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxSimpleUIMarketViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxSimpleUIMarketView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxSimpleUIMarketViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
