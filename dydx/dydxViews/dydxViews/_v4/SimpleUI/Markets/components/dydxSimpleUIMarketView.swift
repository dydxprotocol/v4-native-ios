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

    public enum PositionToggleType {
        case price, pnl, marginUsage
    }

    public let displayType: DisplayType
    public let positionToggleType: PositionToggleType
    public let marketId: String
    public let assetName: String
    public let iconUrl: String?
    public let price: String?
    public let change: SignedAmountViewModel?
    public let unrealizedPNLAmount: SignedAmountViewModel?
    public let marginValue: String?
    public let marginUsage: MarginUsageModel?
    public let sideText: SideTextViewModel
    public let leverage: Double?
    public let volume: Double?
    public let positionTotal: Double?
    public let positionSize: String?
    public let onMarketSelected: (() -> Void)?
    public let isLoading: Bool
    public let marketCaps: Double?
    public let isLaunched: Bool
    public let onCancelAction: (() -> Void)?
    public let isFavorite: Bool
    public let onFavoriteTapped: (() -> Void)?

    var leverageText: String? {
        guard let leverage else { return nil }
        return String(format: "%.2fx", leverage)
    }

    public init(displayType: DisplayType,
                positionToggleType: PositionToggleType,
                marketId: String,
                assetName: String,
                iconUrl: String?,
                price: String?,
                change: SignedAmountViewModel?,
                unrealizedPNLAmount: SignedAmountViewModel?,
                marginValue: String?,
                marginUsage: MarginUsageModel?,
                sideText: SideTextViewModel,
                leverage: Double?,
                volumn: Double?,
                positionTotal: Double?,
                positionSize: String?,
                isLoading: Bool = false,
                marketCaps: Double?,
                isLaunched: Bool,
                isFavorite: Bool,
                onMarketSelected: (() -> Void)?,
                onCancelAction: (() -> Void)?,
                onFavoriteTapped: (() -> Void)?
    ) {
        self.displayType = displayType
        self.positionToggleType = positionToggleType
        self.marketId = marketId
        self.assetName = assetName
        self.iconUrl = iconUrl
        self.price = price
        self.change = change
        self.unrealizedPNLAmount = unrealizedPNLAmount
        self.marginValue = marginValue
        self.marginUsage = marginUsage
        self.sideText = sideText
        self.leverage = leverage
        self.volume = volumn
        self.positionTotal = positionTotal
        self.positionSize = positionSize
        self.isLoading = isLoading
        self.marketCaps = marketCaps
        self.isLaunched = isLaunched
        self.isFavorite = isFavorite
        self.onMarketSelected = onMarketSelected
        self.onCancelAction = onCancelAction
        self.onFavoriteTapped = onFavoriteTapped
    }

    public static var previewValue: dydxSimpleUIMarketViewModel {
        let vm = dydxSimpleUIMarketViewModel(displayType: .market,
                                             positionToggleType: .pnl,
                                             marketId: "ETH-USD",
                                             assetName: "ETH",
                                             iconUrl: "https://assets.coingecko.com/coins/images/1/large/bitcoin.png",
                                             price: "50_000",
                                             change: .previewValue,
                                             unrealizedPNLAmount: .previewValue,
                                             marginValue: "$111.22",
                                             marginUsage: .previewValue,
                                             sideText: .previewValue,
                                             leverage: 1.34,
                                             volumn: nil,
                                             positionTotal: 122333,
                                             positionSize: "$349",
                                             marketCaps: 122000,
                                             isLaunched: true,
                                             isFavorite: true,
                                             onMarketSelected: nil,
                                             onCancelAction: nil,
                                             onFavoriteTapped: nil)
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let assetName = isFavorite ? "action_like" : "action_dislike"
            let leftCellSwipeAccessoryView = PlatformIconViewModel(type: .asset(name: assetName, bundle: Bundle.dydxView), size: .init(width: 16, height: 16))
                .createView(parentStyle: style, styleKey: styleKey)
                .tint(ThemeColor.SemanticColor.layer1.color)
            let leftCellSwipeAccessory = CellSwipeAccessory(accessoryView: AnyView(leftCellSwipeAccessoryView)) {
                self.onFavoriteTapped?()
            }

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
                        HStack {
                            switch self.displayType {
                            case .market:
                                self.createMarketItemView(style: style)
                            case .position:
                                self.createPositionItemView(style: style)
                            }
                        }
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 4)
                        .if(self.onCancelAction != nil, { view in
                            view.swipeActions(leftCellSwipeAccessory: leftCellSwipeAccessory,
                                              rightCellSwipeAccessory: rightCellSwipeAccessory)
                        }, else: { view in
                            view.swipeActions(leftCellSwipeAccessory: leftCellSwipeAccessory,
                                              rightCellSwipeAccessory: nil)
                        })
                    }
                }
            }

            return AnyView(view)
        }
    }

    private func createMarketItemView(style: ThemeStyle) -> some View {
        HStack(spacing: 20) {
            HStack(spacing: 12) {
                self.createIcon(style: style)
                self.createNameVolume(style: style)
            }
            Spacer()

            self.createPriceChange(style: style)
        }
    }

    private func createPositionItemView(style: ThemeStyle) -> some View {
        HStack(spacing: 20) {
            HStack(spacing: 12) {
                self.createIcon(style: style)
                self.createSideSizeValue(style: style)
            }
            Spacer()

            switch self.positionToggleType {
            case .price:
                self.createPriceChange(style: style)
            case .pnl:
                self.createPnl(style: style)
            case .marginUsage:
                self.createMarginUsage(style: style)
            }
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
                                     clip: .circle(background: .colorWhite, spacing: 0),
                                     size: CGSize(width: iconSize, height: iconSize),
                                     backgroundColor: .colorWhite)
            .createView(parentStyle: style)
    }

    private func createSideSizeValue(style: ThemeStyle) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                Text(assetName)
                    .themeColor(foreground: .textPrimary)
                    .themeFont(fontSize: .medium)

                if let leverageText {
                    Text(leverageText)
                        .themeColor(foreground: .textSecondary)
                        .themeFont(fontSize: .smaller)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .themeColor(background: .layer4)
                        .cornerRadius(6, corners: .allCorners)
                }

                if isFavorite {
                    PlatformIconViewModel(type: .asset(name: "action_like", bundle: Bundle.dydxView),
                                          size: CGSize(width: 12, height: 12))
                    .createView(parentStyle: style)
                }
            }

            HStack(spacing: 4) {
                sideText.createView(parentStyle: style.themeFont(fontSize: .small))
                if let positionSize {
                    Text(positionSize)
                        .themeColor(foreground: .textTertiary)
                        .themeFont(fontSize: .small)
                }
            }
        }
    }

    private func createNameVolume(style: ThemeStyle) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .center, spacing: 4) {
                Text(assetName)
                    .themeColor(foreground: .textPrimary)
                    .themeFont(fontSize: .medium)

                if isFavorite {
                    PlatformIconViewModel(type: .asset(name: "action_like", bundle: Bundle.dydxView),
                                          size: CGSize(width: 12, height: 12))
                    .createView(parentStyle: style)
                }
            }

            HStack(spacing: 4) {
                if isLaunched {
                    if let marketCapText = dydxFormatter.shared.dollarVolume(number: marketCaps) {
                        Text(DataLocalizer.localize(path: "APP.GENERAL.MARKET"))
                            .themeColor(foreground: .textTertiary)

                        Text(marketCapText)

                    } else {
                        Text("-")
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

    private func createPnl(style: ThemeStyle) -> some View {
        VStack(alignment: .trailing, spacing: 4) {
            let valueString = dydxFormatter.shared.dollar(number: self.positionTotal, digits: 2)
            Text(valueString ?? "")
                .themeColor(foreground: .textPrimary)
                .themeFont(fontSize: .medium)

            unrealizedPNLAmount?.createView(parentStyle: style.themeFont(fontSize: .small))
        }
    }

    private func createMarginUsage(style: ThemeStyle) -> some View {
        VStack(alignment: .trailing, spacing: 0) {
            Text(marginValue ?? "")
                .themeColor(foreground: .textPrimary)
                .themeFont(fontSize: .medium)

            marginUsage?.createView(parentStyle: style.themeFont(fontType: .base, fontSize: .small))
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
