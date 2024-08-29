//
//  dydxMarketsHeaderView.swift
//  dydxViews
//
//  Created by Rui Huang on 9/1/22.
//  Copyright © 2022 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxMarketsBannerViewModel: PlatformViewModel {
    public var navigationAction: (() -> Void)

    static var previewValue: dydxMarketsBannerViewModel = {
        let vm = dydxMarketsBannerViewModel(navigationAction: {})
        return vm
    }()

    public init(navigationAction: @escaping (() -> Void)) {
        self.navigationAction = navigationAction
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] _ in
            guard let self = self else { return AnyView(PlatformView.nilView) }
            return dydxMarketsBannerView(viewModel: self)
                .wrappedInAnyView()
        }
    }
}

private struct dydxMarketsBannerView: View {
    var viewModel: dydxMarketsBannerViewModel

    var textStack: some View {
        HStack(alignment: .top, spacing: 6) {
            Text("🇺🇸")
                .themeFont(fontType: .base, fontSize: .medium)
            VStack(alignment: .leading, spacing: 4) {
                Text(localizerPathKey: "APP.PREDICTION_MARKET.LEVERAGE_TRADE_US_ELECTION_SHORT")
                    .themeFont(fontType: .base, fontSize: .medium)
                    .themeColor(foreground: .textPrimary)
                Text(localizerPathKey: "APP.PREDICTION_MARKET.WITH_PREDICTION_MARKETS")
                    .themeFont(fontType: .base, fontSize: .small)
                    .themeColor(foreground: .textSecondary)
            }
        }
    }

    var navButton: some View {
        Button(action: viewModel.navigationAction) {
            Text("→")
                .themeFont(fontType: .base, fontSize: .large)
                .themeColor(foreground: .textSecondary)
                .centerAligned()
        }
        .frame(width: 32, height: 32)
        .themeColor(background: .layer6)
        .borderAndClip(style: .circle, borderColor: .layer6)
    }

    var body: some View {
        HStack(spacing: 0) {
            textStack
            Spacer(minLength: 8)
            navButton
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .themeColor(background: .layer1)
        .clipShape(.rect(cornerRadius: 16))
    }
}
