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
    @Published public var onMarketSelectorTap: (() -> Void)?

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
                                      size: CGSize(width: 40, height: 40),
                                      backgroundColor: .colorWhite)
                .createView(parentStyle: parentStyle, styleKey: styleKey)
                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: 4) {
                        Text(sharedMarketViewModel?.assetName ?? "")
                            .themeColor(foreground: .textSecondary)
                            .themeFont(fontType: .base, fontSize: .large)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                        TokenTextViewModel(symbol: sharedMarketViewModel?.assetId ?? "")
                            .createView(parentStyle: parentStyle.themeFont(fontSize: .smallest), styleKey: styleKey)
                    }
                    HStack(alignment: .center, spacing: 4) {
                        Text(sharedMarketViewModel?.indexPrice ?? "")
                            .themeColor(foreground: .textPrimary)
                            .themeFont(fontType: .number, fontSize: .large)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                        sharedMarketViewModel?.priceChangePercent24H?
                            .createView(parentStyle: parentStyle.themeFont(fontSize: .medium), styleKey: styleKey)
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
        .onTapGesture(perform: self.onMarketSelectorTap ?? {})
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style  in
            guard let self = self, self.sharedMarketViewModel != nil else {
                return AnyView(PlatformView.nilView)
            }

            return HStack(spacing: 16) {
                ChevronBackButtonModel(onBackButtonTap: self.onBackButtonTap ?? {})
                    .createView(parentStyle: style)
                    .frame(width: 32)

                self.createMarketSelectorView(parentStyle: parentStyle, styleKey: styleKey)
                    .frame(maxWidth: .infinity)

                self.favoriteViewModel?.createView(parentStyle: style)
                    .frame(width: 32)
            }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 12)
                .wrappedInAnyView()
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
