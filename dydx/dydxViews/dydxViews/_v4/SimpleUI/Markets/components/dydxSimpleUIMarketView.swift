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
import dydxFormatter

public class dydxSimpleUIMarketViewModel: PlatformViewModel {
    public enum DisplayType {
        case market, position
    }

    public let displayType: DisplayType
    public let marketId: String
    public let assetName: String
    public let iconUrl: String?
    public let price: String?
    public let change: SignedAmountViewModel?
    public let sideText: SideTextViewModel
    public let leverage: Double?
    public let volumn: Double?
    public let positionTotal: Double?
    public let positionSize: String?
    public let onMarketSelected: (() -> Void)?
    public let isLoading: Bool
    public let marketCaps: Double?
    public let isLaunched: Bool
    public let onCancelAction: (() -> Void)?

    public init(displayType: DisplayType,
                marketId: String,
                assetName: String,
                iconUrl: String?,
                price: String?,
                change: SignedAmountViewModel?,
                sideText: SideTextViewModel,
                leverage: Double?,
                volumn: Double?,
                positionTotal: Double?,
                positionSize: String?,
                isLoading: Bool = false,
                marketCaps: Double?,
                isLaunched: Bool,
                onMarketSelected: (() -> Void)?,
                onCancelAction: (() -> Void)?
    ) {
        self.displayType = displayType
        self.marketId = marketId
        self.assetName = assetName
        self.iconUrl = iconUrl
        self.price = price
        self.change = change
        self.sideText = sideText
        self.leverage = leverage
        self.volumn = volumn
        self.positionTotal = positionTotal
        self.positionSize = positionSize
        self.isLoading = isLoading
        self.marketCaps = marketCaps
        self.isLaunched = isLaunched
        self.onMarketSelected = onMarketSelected
        self.onCancelAction = onCancelAction
    }

    public static var previewValue: dydxSimpleUIMarketViewModel {
        let vm = dydxSimpleUIMarketViewModel(displayType: .market,
                                             marketId: "ETH-USD",
                                             assetName: "ETH",
                                             iconUrl: "https://assets.coingecko.com/coins/images/1/large/bitcoin.png",
                                             price: "50_000",
                                             change: .previewValue,
                                             sideText: .previewValue,
                                             leverage: 1.34,
                                             volumn: nil,
                                             positionTotal: 122333,
                                             positionSize: "$349",
                                             marketCaps: 122000,
                                             isLaunched: true,
                                             onMarketSelected: nil,
                                             onCancelAction: nil)
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let rightCellSwipeAccessoryView = PlatformIconViewModel(type: .asset(name: "action_cancel", bundle: Bundle.dydxView), size: .init(width: 16, height: 16))
                .createView(parentStyle: style, styleKey: styleKey)
                .tint(ThemeColor.SemanticColor.layer1.color)
            let rightCellSwipeAccessory = CellSwipeAccessory(accessoryView: AnyView(rightCellSwipeAccessoryView)) {
                self.onCancelAction?()
            }

            let view = Group {
                if self.isLoading {
                    self.createLoadingView(style: style)
                } else {
                    Button { [weak self] in
                        self?.onMarketSelected?()
                    } label: {
                        HStack(spacing: 20) {
                            HStack(spacing: 12) {
                                self.createIcon(style: style)
                                switch self.displayType {
                                case .market:
                                    self.createNameVolume(style: style)
                                case .position:
                                    self.createSideSizeValue(style: style)
                                }
                            }
                            Spacer()

                            self.createPriceChange(style: style)
                        }
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 4)
                        .if(self.onCancelAction != nil) { view in
                            view.swipeActions(leftCellSwipeAccessory: nil,
                                               rightCellSwipeAccessory: rightCellSwipeAccessory)
                        }
                    }
                }
            }

            return AnyView(view)
        }
    }

    private func createLoadingView(style: ThemeStyle) -> some View {
        HStack(spacing: 20) {
            HStack(spacing: 12) {
                self.createIcon(style: style)
                    .redacted(reason: .placeholder)
                self.createNameVolume(style: style)
                    .redacted(reason: .placeholder)
            }
            Spacer()

            self.createPriceChange(style: style)
                .redacted(reason: .placeholder)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 4)
    }

    private func createIcon(style: ThemeStyle) -> some View {
        let iconSize: CGFloat = 36
        let placeholderText = { [weak self] in
            if let assetName = self?.assetName {
                return Text(assetName.prefix(1))
                    .frame(width: iconSize, height: iconSize)
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
                                     size: CGSize(width: iconSize, height: iconSize))
            .createView(parentStyle: style)
    }

    private func createSideSizeValue(style: ThemeStyle) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                sideText.createView(parentStyle: style.themeFont(fontSize: .medium))
                if let positionSize {
                    Text(positionSize)
                        .themeColor(foreground: .textPrimary)
                        .themeFont(fontSize: .medium)
                    TokenTextViewModel(symbol: assetName, withBorder: true)
                        .createView(parentStyle: style.themeFont(fontSize: .smallest))
                }
            }

            let valueString = dydxFormatter.shared.dollar(number: self.positionTotal, digits: 2)
            Text(valueString ?? "")
                .themeColor(foreground: .textTertiary)
                .themeFont(fontSize: .small)
        }
    }

    private func createNameVolume(style: ThemeStyle) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(assetName)
                .themeColor(foreground: .textPrimary)
                .themeFont(fontSize: .medium)

            HStack {
                if isLaunched {
                    Text(DataLocalizer.localize(path: "APP.TRADE.VOLUME"))
                        .themeColor(foreground: .textTertiary)

                    if let volumeText = dydxFormatter.shared.dollarVolume(number: volumn) {
                        Text(volumeText)
                    }
                } else {
                    Text(DataLocalizer.localize(path: "APP.GENERAL.LAUNCHABLE"))
                        .themeColor(foreground: .textTertiary)
                }
            }
            .themeFont(fontSize: .small)
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
