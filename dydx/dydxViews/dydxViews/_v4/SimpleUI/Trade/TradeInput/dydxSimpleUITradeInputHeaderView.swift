//
//  dydxSimpleUITradeInputHeaderView.swift
//  dydxUI
//
//  Created by Rui Huang on 16/01/2025.
//  Copyright © 2025 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxSimpleUITradeInputHeaderViewModel: PlatformViewModel {
    @Published public var sharedMarketViewModel: SharedMarketViewModel? = SharedMarketViewModel()
    @Published public var side: SideTextViewModel? = SideTextViewModel()

    public init() { }

    public static var previewValue: dydxSimpleUITradeInputHeaderViewModel {
        let vm = dydxSimpleUITradeInputHeaderViewModel()
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let view = HStack(spacing: 8) {
                self.createIcon(style: style)

                self.createNameSide(style: style)

                Spacer()

                self.createPriceChange(style: style)
            }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 12)

            return AnyView(view)
        }
    }

    private func createIcon(style: ThemeStyle) -> some View {
        let placeholderText = { [weak self] in
            if let assetName = self?.sharedMarketViewModel?.assetName {
                return Text(assetName.prefix(1))
                    .frame(width: 32, height: 32)
                    .themeColor(foreground: .textTertiary)
                    .themeColor(background: .layer5)
                    .borderAndClip(style: .circle, borderColor: .layer7, lineWidth: 1)
                    .wrappedInAnyView()
            }
            return AnyView(PlatformView.nilView)
        }
        let iconType = PlatformIconViewModel.IconType.url(url: sharedMarketViewModel?.logoUrl, placeholderContent: placeholderText)
        return PlatformIconViewModel(type: iconType,
                                     clip: .circle(background: .transparent, spacing: 0),
                                     size: CGSize(width: 32, height: 32))
            .createView(parentStyle: style)
    }

    private func createNameSide(style: ThemeStyle) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(sharedMarketViewModel?.assetId ?? "")
                .themeColor(foreground: .textPrimary)
                .themeFont(fontSize: .medium)

            side?.createView(parentStyle: style)
        }
    }

    private func createPriceChange(style: ThemeStyle) -> some View {
        VStack(alignment: .trailing, spacing: 4) {
            Text(sharedMarketViewModel?.indexPrice ?? "")
                .themeColor(foreground: .textPrimary)
                .themeFont(fontSize: .medium)

            sharedMarketViewModel?.priceChangePercent24H?.createView(parentStyle: style.themeFont(fontSize: .small))
        }
    }
}

#if DEBUG
struct dydxSimpleUITradeInputHeaderView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxSimpleUITradeInputHeaderViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxSimpleUITradeInputHeaderView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxSimpleUITradeInputHeaderViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
