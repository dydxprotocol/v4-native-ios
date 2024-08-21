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
import Charts
import dydxFormatter

public class dydxVaultPositionViewModel: PlatformViewModel {
    static var marketSectionWidth: CGFloat = 130
    static var interSectionPadding: CGFloat = 12
    static var sparklineWidth: CGFloat = 24
    static var pnlSpacing: CGFloat = 3

    @Published public var assetName: String
    @Published public var market: String
    @Published public var side: SideTextViewModel.Side
    @Published public var leverage: Double
    @Published public var notionalValue: Double
    @Published public var positionSize: Double
    @Published public var tokenUnitPrecision: Int
    @Published public var token: String
    @Published public var pnlAmount: Double
    @Published public var pnlPercentage: Double
    @Published public var sparklineValues: [Double]
    
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
        dydxFormatter.shared.dollar(number: notionalValue) ?? "--"
    }
    
    fileprivate var positionSizeText: String {
        dydxFormatter.shared.localFormatted(number: positionSize, digits: tokenUnitPrecision) ?? "--"
    }
    
    fileprivate var pnlColor: ThemeColor.SemanticColor {
        pnlAmount >= 0 ? ThemeSettings.positiveColor : ThemeSettings.negativeColor
    }
    
    fileprivate var pnlAmountText: String {
        dydxFormatter.shared.dollar(number: pnlAmount) ?? "--"
    }
    
    fileprivate var pnlPercentageText: String {
        dydxFormatter.shared.percent(number: pnlPercentage, digits: 2) ?? "--"
    }
    
    public init(
        assetName: String,
        market: String,
        side: SideTextViewModel.Side,
        leverage: Double,
        notionalValue: Double,
        positionSize: Double,
        token: String,
        tokenUnitPrecision: Int,
        pnlAmount: Double,
        pnlPercentage: Double,
        sparklineValues: [Double]) {
            self.assetName = assetName
            self.market = market
            self.side = side
            self.leverage = leverage
            self.notionalValue = notionalValue
            self.positionSize = positionSize
            self.token = token
            self.tokenUnitPrecision = tokenUnitPrecision
            self.pnlAmount = pnlAmount
            self.pnlPercentage = pnlPercentage
            self.sparklineValues = sparklineValues
    }
    
    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style  in
            guard let self = self else { return AnyView(PlatformView.nilView) }
            return VaultPositionView(viewModel: self)
                .wrappedInAnyView()
        }
    }
}

private struct VaultPositionView: View {
    @ObservedObject var viewModel: dydxVaultPositionViewModel
    
    var marketSection: some View {
        HStack(spacing: 8) {
            PlatformIconViewModel(type: .asset(name: viewModel.assetName, bundle: .dydxView),
                                  clip: .circle(background: .transparent, spacing: 0, borderColor: nil),
                                  size: .init(width: 24, height: 24),
                                  templateColor: nil)
                .createView()
            VStack(alignment: .leading, spacing: 2) {
                Text(viewModel.market)
                    .themeFont(fontType: .base, fontSize: .small)
                    .themeColor(foreground: .textSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                Text(viewModel.sideLeverageAttributedText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }
        }
        .leftAligned()
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
                TokenTextViewModel(symbol: viewModel.token)
                    .createView(parentStyle: ThemeStyle.defaultStyle.themeFont(fontSize: .smallest))
            }
        }
        .leftAligned()
    }
    
    var pnlSection: some View {
        HStack(alignment: .center, spacing: dydxVaultPositionViewModel.pnlSpacing) {
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
            SparklineView(values: viewModel.sparklineValues)
                .frame(width: dydxVaultPositionViewModel.sparklineWidth, height: 24)
        }
    }
    
    var body: some View {
        HStack(spacing: dydxVaultPositionViewModel.interSectionPadding) {
                marketSection
                    .frame(width: dydxVaultPositionViewModel.marketSectionWidth)
                sizeSection
                pnlSection
            }
    }
}

