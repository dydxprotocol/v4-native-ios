//
//  dydxVaultPositionView.swift
//  dydxUI
//
//  Created by Michael Maguire on 8/14/24.
//  Copyright © 2024 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities
import DGCharts
import dydxFormatter
import SDWebImage
import SDWebImageSwiftUI

public class dydxVaultPositionViewModel: PlatformViewModel {

    @Published public var marketId: String
    @Published public var displayId: String
    @Published public var symbol: String?
    @Published public var iconType: PlatformIconViewModel.IconType = .init(url: nil, placeholderText: nil)
    @Published public var side: SideTextViewModel.Side
    @Published public var leverage: Double?
    @Published public var equity: Double
    @Published public var notionalValue: Double
    @Published public var positionSize: Double
    @Published public var tokenUnitPrecision: Int
    @Published public var pnlAmount: Double?
    @Published public var pnlPercentage: Double?
    @Published public var sparklineValues: [Double]?

    fileprivate var sideLeverageAttributedText: AttributedString {
        let attributedSideText = AttributedString(text: side.text, urlString: nil)
            .themeColor(foreground: side.color)
        let leverageText = dydxFormatter.shared.leverage(number: leverage) ?? "--"
        let attributedLeverageText = AttributedString(text: "@ " + leverageText, urlString: nil)
            .themeColor(foreground: .textTertiary)
        return (attributedSideText + attributedLeverageText)
                .themeFont(fontType: .base, fontSize: .smaller)
    }

    fileprivate var notionalValueText: String {
        let size = dydxFormatter.shared.condensedDollar(number: notionalValue, digits: 0) ?? "--"
        let equity = dydxFormatter.shared.condensedDollar(number: equity, digits: 0) ?? "--"
        return "\(size) / \(equity)"
    }

    fileprivate var positionSizeText: String {
        dydxFormatter.shared.condensed(number: positionSize, digits: tokenUnitPrecision) ?? "--"
    }

    fileprivate var pnlColor: ThemeColor.SemanticColor {
        if let pnlAmount = pnlAmount {
            return pnlAmount >= 0 ? ThemeSettings.positiveColor : ThemeSettings.negativeColor
        } else {
            return .textTertiary
        }
    }

    fileprivate var pnlAmountText: String {
        dydxFormatter.shared.condensedDollar(number: pnlAmount, digits: 2) ?? "--"
    }

    fileprivate var pnlPercentageText: String {
        dydxFormatter.shared.percent(number: pnlPercentage, digits: 2) ?? "--"
    }

    public init(
        marketId: String,
        displayId: String,
        symbol: String?,
        iconType: PlatformIconViewModel.IconType,
        side: SideTextViewModel.Side,
        leverage: Double?,
        equity: Double,
        notionalValue: Double,
        positionSize: Double,
        tokenUnitPrecision: Int,
        pnlAmount: Double?,
        pnlPercentage: Double?,
        sparklineValues: [Double]?) {
            self.marketId = marketId
            self.displayId = displayId
            self.symbol = symbol
            self.iconType = iconType
            self.side = side
            self.leverage = leverage
            self.equity = equity
            self.notionalValue = notionalValue
            self.positionSize = positionSize
            self.tokenUnitPrecision = tokenUnitPrecision
            self.pnlAmount = pnlAmount
            self.pnlPercentage = pnlPercentage
            self.sparklineValues = sparklineValues
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformUI.PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] _  in
            guard let self = self else { return AnyView(PlatformView.nilView) }
            return VaultPositionView(viewModel: self)
                .wrappedInAnyView()
        }
    }
}

struct VaultPositionView: View {

    static let marketSectionWidth: CGFloat = 130
    static let interSectionPadding: CGFloat = 12
    static let sparklineWidth: CGFloat = 24
    static let pnlSpacing: CGFloat = 6

    @ObservedObject var viewModel: dydxVaultPositionViewModel

    var marketSection: some View {
        HStack(spacing: 8) {
            PlatformIconViewModel(type: viewModel.iconType,
                                  clip: PlatformIconViewModel.IconClip.circle(background: ThemeColor.SemanticColor.transparent, spacing: 0, borderColor: nil))
                .createView()
            VStack(alignment: .leading, spacing: 2) {
                Text(viewModel.displayId)
                    .themeFont(fontType: .base, fontSize: .small)
                    .themeColor(foreground: .textSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                Text(viewModel.sideLeverageAttributedText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }
            Spacer()
        }
    }

    var sizeSection: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(viewModel.notionalValueText)
                .themeFont(fontType: .base, fontSize: .small)
                .themeColor(foreground: .textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            HStack(alignment: .top, spacing: 2) {
                Text(viewModel.positionSizeText)
                    .themeFont(fontType: .base, fontSize: .smaller)
                    .themeColor(foreground: .textTertiary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                if let symbol = viewModel.symbol {
                    TokenTextViewModel(symbol: symbol)
                        .createView(parentStyle: ThemeStyle.defaultStyle.themeFont(fontSize: .smallest))
                }
            }
        }
        .leftAligned()
    }

    var pnlSection: some View {
        HStack(alignment: .center, spacing: Self.pnlSpacing) {
            VStack(alignment: .trailing, spacing: 2) {
                Text(viewModel.pnlAmountText)
                    .themeFont(fontType: .base, fontSize: .small)
                    .themeColor(foreground: viewModel.pnlColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                Text(viewModel.pnlPercentageText)
                    .themeFont(fontType: .base, fontSize: .smaller)
                    .themeColor(foreground: .textTertiary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }
            SparklineView(values: viewModel.sparklineValues ?? [])
                .frame(width: Self.sparklineWidth, height: 24)
        }
    }

    var body: some View {
        HStack(spacing: Self.interSectionPadding) {
                marketSection
                    .frame(width: Self.marketSectionWidth)
                sizeSection
                pnlSection
            }
    }
}
