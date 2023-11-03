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
    @Published public var favoriteViewModel: dydxUserFavoriteViewModel? = dydxUserFavoriteViewModel()
    @Published public var onBackButtonTap: (() -> Void)?

    public init() { }

    public static var previewValue: dydxMarketInfoHeaderViewModel = {
        let vm = dydxMarketInfoHeaderViewModel()
        vm.sharedMarketViewModel = .previewValue
        vm.favoriteViewModel = .previewValue
        return vm
    }()

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style  in
            guard let self = self, let sharedMarketViewModel = self.sharedMarketViewModel else {
                return AnyView(PlatformView.nilView)
            }

            return AnyView(
                HStack(spacing: 0) {
                    ChevronBackButtonModel(onBackButtonTap: self.onBackButtonTap ?? {})
                        .createView(parentStyle: style)

                    let icon = PlatformIconViewModel(type: .url(url: sharedMarketViewModel.logoUrl),
                                                     clip: .defaultCircle,
                                                     size: CGSize(width: 40, height: 40))

                    let main =
                        HStack {
                            VStack(alignment: .leading) {
                                HStack(spacing: 4) {
                                    Text(sharedMarketViewModel.tokenFullName ?? "")
                                        .themeColor(foreground: .textPrimary)
                                        .themeFont(fontType: .bold, fontSize: .medium)
                                    Text("USD")
                                        .themeFont(fontType: .bold, fontSize: .medium)

                                }
                                Text(sharedMarketViewModel.tokenSymbol ?? "")
                                    .themeFont(fontType: .text, fontSize: .small)
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
                                .themeFont(fontType: .bold, fontSize: .medium)
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
