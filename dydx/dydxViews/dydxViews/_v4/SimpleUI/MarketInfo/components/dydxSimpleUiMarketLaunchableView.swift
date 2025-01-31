//
//  dydxSimpleUiMarketLaunchableView.swift
//  dydxUI
//
//  Created by Rui Huang on 01/02/2025.
//  Copyright © 2025 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxSimpleUiMarketLaunchableViewModel: PlatformViewModel {
    @Published public var sharedMarketViewModel: SharedMarketViewModel? = SharedMarketViewModel()

    public init() { }

    public static var previewValue: dydxSimpleUiMarketLaunchableViewModel {
        let vm = dydxSimpleUiMarketLaunchableViewModel()
        vm.sharedMarketViewModel = .previewValue
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let view = VStack(spacing: 24) {
                self.createLaunchableText(style: style)
                self.createHeader(style: style)
                self.createDetails(style: style)
                Spacer()
            }
                .padding(.top, 24)
                .padding(.horizontal, 20)

            return AnyView(view)
        }
    }

    private func createLaunchableText(style: ThemeStyle) -> some View {
        HStack {
            Spacer()
            PlatformIconViewModel(type: .system(name: "info.circle.fill"),
                                  size: CGSize(width: 20, height: 20),
                                  templateColor: .textTertiary)
            .createView(parentStyle: style)
            Text(DataLocalizer.localize(path: "APP.GENERAL.LAUNCHABLE_DETAILS"))
                .themeColor(foreground: .textPrimary)
                .themeFont(fontSize: .small)
            Spacer()
        }
        .padding(8)
        .borderAndClip(style: .cornerRadius(8), borderColor: .borderDefault)
    }

    private func createHeader(style: ThemeStyle) -> some View {
        HStack(alignment: .center) {
            Text(DataLocalizer.localize(path: "APP.GENERAL.DETAILS"))
                .themeFont(fontType: .plus, fontSize: .large)
                .themeColor(foreground: .textPrimary)

            Spacer()

            HStack {
                dydxSimpleUIMarketDetailsViewModel.createIconButton(url: sharedMarketViewModel?.coinMarketPlaceUrl, iconAssetName: "icon_coinmarketcap", style: style)
                dydxSimpleUIMarketDetailsViewModel.createIconButton(url: sharedMarketViewModel?.whitepaperUrl, iconAssetName: "icon_whitepaper", style: style)
                dydxSimpleUIMarketDetailsViewModel.createIconButton(url: sharedMarketViewModel?.websiteUrl, iconAssetName: "icon_web", style: style)
            }
        }
    }

    private func createDetails(style: ThemeStyle) -> some View {
        HStack {
            let nameHeader = Text(DataLocalizer.localize(path: "APP.GENERAL.MARKET_NAME"))
                .themeFont(fontType: .plus, fontSize: .small)
                .themeColor(foreground: .textTertiary)
            CollectionItemUtil.createCollectionItem(parentStyle: style,
                                                    titleViewModel: nameHeader.wrappedViewModel,
                                                    value: sharedMarketViewModel?.assetName)
            .frame(minWidth: 0, maxWidth: .infinity)

            let marketCapHeader = HStack {
                Text(DataLocalizer.localize(path: "APP.GENERAL.MARKET_CAP"))
                    .themeFont(fontType: .plus, fontSize: .small)
                    .themeColor(foreground: .textTertiary)
                TokenTextViewModel(symbol: "USD", withBorder: true)
                    .createView(parentStyle: style.themeFont(fontSize: .smallest))
            }
            CollectionItemUtil.createCollectionItem(parentStyle: style,
                                                    titleViewModel: marketCapHeader.wrappedViewModel,
                                                    value: sharedMarketViewModel?.marketCap)
            .frame(minWidth: 0, maxWidth: .infinity)

            let volumeCapHeader = HStack {
                Text(DataLocalizer.localize(path: "APP.TRADE.SPOT_VOLUME_24H"))
                    .themeFont(fontType: .plus, fontSize: .small)
                    .themeColor(foreground: .textTertiary)
                TokenTextViewModel(symbol: "USD", withBorder: true)
                    .createView(parentStyle: style.themeFont(fontSize: .smallest))
            }
            CollectionItemUtil.createCollectionItem(parentStyle: style,
                                                    titleViewModel: volumeCapHeader.wrappedViewModel,
                                                    value: sharedMarketViewModel?.spotVolume24H)
            .frame(minWidth: 0, maxWidth: .infinity)
        }
    }
}

#if DEBUG
struct dydxSimpleUiMarketLaunchableView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxSimpleUiMarketLaunchableViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxSimpleUiMarketLaunchableView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxSimpleUiMarketLaunchableViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
