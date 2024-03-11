//
//  dydxMarketInfoHeaderView.swift
//  dydxViews
//
//  Created by Rui Huang on 10/6/22.
//  Copyright © 2022 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxMarketInfoHeaderViewModel: PlatformViewModel {
    @Published public var sharedMarketViewModel: SharedMarketViewModel? = SharedMarketViewModel()
    @Published public var favoriteViewModel: dydxUserFavoriteViewModel? = dydxUserFavoriteViewModel(size: .init(width: 20, height: 20))
    @Published public var onBackButtonTap: (() -> Void)?

    public init() {}

    public static var previewValue: dydxMarketInfoHeaderViewModel = {
        let vm = dydxMarketInfoHeaderViewModel()
        vm.sharedMarketViewModel = .previewValue
        vm.favoriteViewModel = .previewValue
        return vm
    }()

    private func createMarketSelectorView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> some View {
        HStack(spacing: 15) {
            HStack(spacing: 12) {
                PlatformIconViewModel(type: .url(url: self.sharedMarketViewModel?.logoUrl),
                                      clip: .defaultCircle,
                                      size: CGSize(width: 40, height: 40))
                .createView(parentStyle: parentStyle, styleKey: styleKey)
                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: 4) {
                        Text(sharedMarketViewModel?.tokenFullName ?? "")
                            .themeColor(foreground: .textSecondary)
                            .themeFont(fontType: .text, fontSize: .large)
                        TokenTextViewModel(symbol: sharedMarketViewModel?.tokenSymbol ?? "")
                            .createView(parentStyle: parentStyle.themeFont(fontSize: .smallest), styleKey: styleKey)
                    }
                    HStack(alignment: .center, spacing: 4) {
                        Text(sharedMarketViewModel?.indexPrice ?? "")
                            .themeColor(foreground: .textPrimary)
                            .themeFont(fontType: .number, fontSize: .large)
                        sharedMarketViewModel?.priceChangePercent24H?.createView(parentStyle: parentStyle.themeFont(fontSize: .medium), styleKey: styleKey)
                    }
                }
            }
            PlatformIconViewModel(type: .asset(name: "icon_dropdown", bundle: .dydxView),
                                  clip: .noClip,
                                  size: .init(width: 14, height: 8))
            .createView(parentStyle: parentStyle, styleKey: styleKey)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .themeColor(background: .layer3)
        .borderAndClip(style: .cornerRadius(12), borderColor: .borderDefault, lineWidth: 1)
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style  in
            guard let self = self, let sharedMarketViewModel = self.sharedMarketViewModel else {
                return AnyView(PlatformView.nilView)
            }

            return HStack(spacing: 28) {
                ChevronBackButtonModel(onBackButtonTap: self.onBackButtonTap ?? {})
                    .createView(parentStyle: style)

                self.createMarketSelectorView(parentStyle: parentStyle, styleKey: styleKey)

                    let main =
                        HStack {
                            VStack(alignment: .leading) {
                                HStack(spacing: 4) {
                                    Text(sharedMarketViewModel.tokenFullName ?? "")
                                        .themeColor(foreground: .textPrimary)
                                        .themeFont(fontType: .plus, fontSize: .medium)
                                    Text("USD")
                                        .themeFont(fontType: .plus, fontSize: .medium)

                                }
                                Text(sharedMarketViewModel.tokenSymbol ?? "")
                                    .themeFont(fontType: .base, fontSize: .small)
                            }

                            self.favoriteViewModel?.createView(parentStyle: style)
                                .padding(.leading, 4)
                                .padding(.top, -18)

                            Spacer()
                        }

                    let trailing =
                        VStack(alignment: .trailing, spacing: 2) {
                            Text(sharedMarketViewModel.indexPrice ?? "")
                                .themeColor(foreground: .textPrimary)
                                .themeFont(fontType: .plus, fontSize: .medium)
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)
                            if let priceChangePercent24H = sharedMarketViewModel.priceChangePercent24H {
                                priceChangePercent24H
                                    .createView(parentStyle: style, styleKey: "asset_list_item_24h_volume")
                            }
                        }
                    PlatformTableViewCellViewModel(logo: icon,
                                                   main: main.wrappedViewModel,
                                                   trailing: trailing.wrappedViewModel)
                        .createView(parentStyle: style)
                }
                .frame(height: 72)
                .padding([.leading])
            )
        }
    }
}

#if DEBUG
struct dydxMarketInfoHeaderView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxMarketInfoHeaderViewModel.previewValue
            .createView()
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxMarketInfoHeaderView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxMarketInfoHeaderViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
