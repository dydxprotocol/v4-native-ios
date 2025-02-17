//
//  dydxSimpleUIMarketDetailsView.swift
//  dydxUI
//
//  Created by Rui Huang on 15/01/2025.
//  Copyright © 2025 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxSimpleUIMarketDetailsViewModel: PlatformViewModel {
    @Published public var sharedMarketViewModel: SharedMarketViewModel? = SharedMarketViewModel()

    public init() { }

    public static var previewValue: dydxSimpleUIMarketDetailsViewModel {
        let vm = dydxSimpleUIMarketDetailsViewModel()
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            return AnyView(
                self.createContent(style: style)
                    .sectionHeader {
                        self.createHeader(style: style)
                            .themeColor(background: .layer1)
                    }
            )
        }
    }

    private func createContent(style: ThemeStyle) -> some View {
        var allText = ""
        if let primaryDescription = sharedMarketViewModel?.primaryDescription {
            allText = primaryDescription
        }
        if let secondaryDescription = sharedMarketViewModel?.secondaryDescription {
            allText = allText + "\n\n" + secondaryDescription
        }
        return VStack(alignment: .leading, spacing: 12) {
            if allText.isNotEmpty {
                ExpandableText(text: allText)
                    .themeFont(fontSize: .medium)
                    .themeColor(foreground: .textSecondary)
                    .expandButton(TextSet(text: DataLocalizer.localize(path: "APP.HEADER.MORE"),
                                          fontSize: .medium))
                    .expandAnimation(.easeOut)
                    .lineLimit(2)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
            }
            HStack {
                let nameHeader = Text(DataLocalizer.localize(path: "APP.GENERAL.MARKET_NAME"))
                    .themeFont(fontType: .plus, fontSize: .small)
                    .themeColor(foreground: .textTertiary)
                CollectionItemUtil.createCollectionItem(parentStyle: style,
                                                        titleViewModel: nameHeader.wrappedViewModel,
                                                        value: sharedMarketViewModel?.assetName)
                .frame(minWidth: 0, maxWidth: .infinity)

                let fundingHeader = Text(DataLocalizer.localize(path: "APP.TRADE.CURRENT_FUNDING_RATE"))
                    .themeFont(fontType: .plus, fontSize: .small)
                    .themeColor(foreground: .textTertiary)
                CollectionItemUtil.createCollectionItem(parentStyle: style,
                                                        titleViewModel: fundingHeader.wrappedViewModel,
                                                        valueViewModel: sharedMarketViewModel?.fundingRate)
                .frame(minWidth: 0, maxWidth: .infinity)
            }
            .padding(.horizontal, 16)

            HStack {
                let openInterestHeader = HStack {
                    Text(DataLocalizer.localize(path: "APP.TRADE.OPEN_INTEREST"))
                        .themeFont(fontType: .plus, fontSize: .small)
                        .themeColor(foreground: .textTertiary)
                    TokenTextViewModel(symbol: "USD", withBorder: true)
                        .createView(parentStyle: style.themeFont(fontSize: .smallest))
                }
                CollectionItemUtil.createCollectionItem(parentStyle: style,
                                                        titleViewModel: openInterestHeader.wrappedViewModel,
                                                        value: sharedMarketViewModel?.openInterest)
                .frame(minWidth: 0, maxWidth: .infinity)

                let buyingPowerHeader = HStack {
                    Text(DataLocalizer.localize(path: "APP.GENERAL.BUYING_POWER"))
                        .themeFont(fontType: .plus, fontSize: .small)
                        .themeColor(foreground: .textTertiary)
                    TokenTextViewModel(symbol: "USD", withBorder: true)
                        .createView(parentStyle: style.themeFont(fontSize: .smallest))
                }
                CollectionItemUtil.createCollectionItem(parentStyle: style,
                                                        titleViewModel: buyingPowerHeader.wrappedViewModel,
                                                        value: sharedMarketViewModel?.buyingPower)
                .frame(minWidth: 0, maxWidth: .infinity)

            }
            .padding(.horizontal, 16)
        }
    }

    private func createHeader(style: ThemeStyle) -> some View {
        VStack {
            HStack(alignment: .center) {
                Text(DataLocalizer.localize(path: "APP.GENERAL.DETAILS"))
                    .themeFont(fontType: .plus, fontSize: .large)
                    .themeColor(foreground: .textPrimary)
                    .padding(.leading, 16)

                Spacer()

                HStack {
                    Self.createIconButton(url: sharedMarketViewModel?.coinMarketPlaceUrl, iconAssetName: "icon_coinmarketcap", style: style)
                    Self.createIconButton(url: sharedMarketViewModel?.whitepaperUrl, iconAssetName: "icon_whitepaper", style: style)
                    Self.createIconButton(url: sharedMarketViewModel?.websiteUrl, iconAssetName: "icon_web", style: style)
                }
            }
            .padding(.trailing, 16)

            Spacer(minLength: 24)
        }
    }

    static func createIconButton(url: URL?, iconAssetName: String, style: ThemeStyle) -> AnyView {
        if let url = url {
            let icon = PlatformIconViewModel(type: .asset(name: iconAssetName, bundle: Bundle.dydxView),
                                             clip: .circle(background: .layer4, spacing: 16),
                                             size: CGSize(width: 40, height: 40))
            return AnyView(
                Link(destination: url) {
                    PlatformButtonViewModel(content: icon, type: .iconType) {
                        if URLHandler.shared?.canOpenURL(url) ?? false {
                            URLHandler.shared?.open(url, completionHandler: nil)
                        }
                    }
                    .createView(parentStyle: style)
                }
            )

        } else {
            return AnyView(
                PlatformView.nilView
            )
        }
    }
}

#if DEBUG
struct dydxSimpleUIMarketDetailsView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxSimpleUIMarketDetailsViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxSimpleUIMarketDetailsView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxSimpleUIMarketDetailsViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
