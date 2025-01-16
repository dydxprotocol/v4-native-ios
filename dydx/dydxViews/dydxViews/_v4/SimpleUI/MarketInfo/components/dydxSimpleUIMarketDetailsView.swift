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
                    }
            )
        }
    }

    private func createContent(style: ThemeStyle) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Group {
                if let primaryDescription = sharedMarketViewModel?.primaryDescription {
                    Text(primaryDescription)
                }
                if let secondaryDescription = sharedMarketViewModel?.secondaryDescription {
                    Text(secondaryDescription)
                }
            }
                .themeFont(fontSize: .medium)
                .themeColor(foreground: .textSecondary)
                .padding(.horizontal, 16)

            HStack {
                let fundingHeader = Text(DataLocalizer.localize(path: "APP.TRADE.NEXT_FUNDING"))
                    .themeFont(fontType: .plus, fontSize: .small)
                    .themeColor(foreground: .textTertiary)
                CollectionItemUtil.createCollectionItem(parentStyle: style,
                                                        titleViewModel: fundingHeader.wrappedViewModel,
                                                        valueViewModel: sharedMarketViewModel?.nextFunding)
                .frame(minWidth: 0, maxWidth: .infinity)

                let openInterestHeader = HStack {
                    Text(DataLocalizer.localize(path: "APP.TRADE.OPEN_INTEREST"))
                        .themeFont(fontType: .plus, fontSize: .small)
                        .themeColor(foreground: .textTertiary)
                    TokenTextViewModel(symbol: "USD")
                        .createView(parentStyle: style.themeFont(fontSize: .smallest))
                }
                CollectionItemUtil.createCollectionItem(parentStyle: style,
                                                        titleViewModel: openInterestHeader.wrappedViewModel,
                                                        value: sharedMarketViewModel?.openInterest)
                .frame(minWidth: 0, maxWidth: .infinity)
            }
            .padding(.horizontal, 16)
        }
    }

    private func createCollectionItem(parentStyle: ThemeStyle, titleViewModel: PlatformViewModel?, valueViewModel: PlatformViewModel?) -> some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                titleViewModel?.createView(parentStyle: parentStyle)
                valueViewModel?.createView(parentStyle: parentStyle, styleKey: nil)
            }
            Spacer()
        }
        .leftAligned()
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
                    createIconButton(url: sharedMarketViewModel?.coinMarketPlaceUrl, iconAssetName: "icon_coinmarketcap", style: style)
                    createIconButton(url: sharedMarketViewModel?.whitepaperUrl, iconAssetName: "icon_whitepaper", style: style)
                    createIconButton(url: sharedMarketViewModel?.websiteUrl, iconAssetName: "icon_web", style: style)
                }
            }
            .padding(.trailing, 16)

            Spacer(minLength: 24)
        }
    }

    private func createIconButton(url: URL?, iconAssetName: String, style: ThemeStyle) -> AnyView {
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
