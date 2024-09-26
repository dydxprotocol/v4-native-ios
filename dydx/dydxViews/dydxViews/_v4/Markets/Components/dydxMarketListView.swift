//
//  dydxMarketListViewModel.swift
//  dydxViews
//
//  Created by Rui Huang on 9/29/22.
//  Copyright © 2022 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities
import dydxFormatter

public class dydxMarketListViewModel: PlatformViewModeling {
    @Published public var markets = [dydxMarketViewModel]()
    
    public init() {}
    
    public static var previewValue: dydxMarketListViewModel = {
        let vm = dydxMarketListViewModel()
        vm.markets = [
            dydxMarketViewModel(symbol: "BTC",
                                iconUrl: "https://assets.coingecko.com/coins/images/1/large/bitcoin.png",
                                volume24H : 1_000_000_000,
                                sparkline: [1, 2, 3, 4, 5],
                                price: 50_000,
                                change: 0.05),
            dydxMarketViewModel(symbol: "ETH",
                                iconUrl: "https://assets.coingecko.com/coins/images/279/large/ethereum.png",
                                volume24H: 500_000_000,
                                sparkline: [5, 4, 3, 2, 1],
                                price: 3_000,
                                change: -0.05)
        ]
        return vm
    }()
    
    public func createView(parentStyle: ThemeStyle = .defaultStyle, styleKey: String? = nil) -> some View {
        dydxMarketListView(viewModel: self)
    }
}


private struct dydxMarketListView: View {
    @ObservedObject var viewModel: dydxMarketListViewModel

    var body: some View {
        ForEach(viewModel.markets, id: \.symbol) { market in
            dydxMarketView(viewModel: market)
        }
    }
}

public class dydxMarketViewModel {
    public let symbol: String
    public let iconUrl: String?
    public let volume24H: Double?
    public let sparkline: [Double]?
    public let price: Double?
    public let change: Double?
    
    public var isPositive: Bool {
        change ?? 0 >= 0
    }
    
    public init(symbol: String,
                iconUrl: String?,
                volume24H: Double?,
                sparkline: [Double]?,
                price: Double?,
                change: Double?) {
        self.symbol = symbol
        self.iconUrl = iconUrl
        self.volume24H = volume24H
        self.sparkline = sparkline
        self.price = price
        self.change = change
    }
}

struct dydxMarketView: View {
    let viewModel: dydxMarketViewModel
    
    @ViewBuilder
    var sparkline: some View {
        if let sparkline = viewModel.sparkline {
            SparklineView(values: sparkline)
                .padding(.vertical, 4)
                .frame(idealHeight: 0)
                .frame(width: 50)
        }
    }
    
    var icon: some View {
        let placeholderText =  { Text(viewModel.symbol.prefix(1))
                .frame(width: 32, height: 32)
                .themeColor(foreground: .textTertiary)
                .themeColor(background: .layer5)
                .borderAndClip(style: .circle, borderColor: .layer7, lineWidth: 1)
                .wrappedInAnyView()
        }
        return PlatformIconViewModel(type: .url(url: URL(string: viewModel.iconUrl ?? ""), placeholderContent: placeholderText),
                              clip: .circle(background: .transparent, spacing: 0),
                              size: CGSize(width: 32, height: 32))
            .createView()
    }
    
    @ViewBuilder
    var nameVolumeVStack: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(viewModel.symbol)
                .themeFont(fontType: .plus, fontSize: .medium)
                .themeColor(foreground: .textPrimary)
            Text(dydxFormatter.shared.dollarVolume(number: viewModel.volume24H) ?? "--")
                .themeFont(fontType: .base, fontSize: .small)
                .themeColor(foreground: .textSecondary)
        }
    }
    
    var priceChangeVStack: some View {
        VStack(alignment: .trailing, spacing: 2) {
            Text(dydxFormatter.shared.dollar(number: viewModel.price) ?? "--")
                .themeFont(fontType: .plus, fontSize: .medium)
                .themeColor(foreground: .textPrimary)
            SignedAmountViewModel(amount: viewModel.change, displayType: .percent, coloringOption: .allText)
                .createView(parentStyle: ThemeStyle.defaultStyle.themeFont(fontSize: .small))
        }
    }
    
    var body: some View {
        HStack(spacing: 20) {
            HStack(spacing: 12) {
                icon
                nameVolumeVStack
            }
            .leftAligned()
            
            sparkline
            
            priceChangeVStack
                .rightAligned()
        }
        .lineLimit(1)
        .minimumScaleFactor(0.5)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .themeGradient(background: .layer3, gradientType: viewModel.isPositive ? .plus : .minus)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
