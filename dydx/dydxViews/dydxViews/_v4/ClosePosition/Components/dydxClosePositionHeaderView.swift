//
//  dydxClosePositionHeaderView.swift
//  dydxViews
//
//  Created by Rui Huang on 2/17/23.
//  Copyright © 2023 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxClosePositionHeaderViewModel: PlatformViewModel {
    @Published public var sharedMarketViewModel: SharedMarketViewModel? = SharedMarketViewModel()
    @Published public var sideViewModel: SideTextViewModel?

    public init() { }

    public static var previewValue: dydxClosePositionHeaderViewModel {
        let vm = dydxClosePositionHeaderViewModel()
        vm.sharedMarketViewModel = .previewValue
        vm.sideViewModel = .previewValue
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self, let sharedMarketViewModel = self.sharedMarketViewModel else {
                return AnyView(PlatformView.nilView)
            }

            return AnyView(
                VStack {
                    let icon = PlatformIconViewModel(type: .url(url: sharedMarketViewModel.logoUrl),
                                                     clip: .defaultCircle,
                                                     size: CGSize(width: 40, height: 40),
                                                     backgroundColor: .colorWhite)

                    let main =
                        Text(DataLocalizer.localize(path: "APP.GENERAL.CLOSE", params: nil))
                            .themeFont(fontType: .plus, fontSize: .largest)

                    let trailing =
                        HStack {
                            self.sideViewModel?.createView(parentStyle: style)

                            VStack(alignment: .trailing, spacing: 2) {
                                Text(sharedMarketViewModel.indexPrice ?? "")
                                    .themeColor(foreground: .textPrimary)
                                    .themeFont(fontType: .plus, fontSize: .medium)
                                    .lineLimit(1)
                                if let priceChangePercent24H = sharedMarketViewModel.priceChangePercent24H {
                                    priceChangePercent24H
                                        .createView(parentStyle: style, styleKey: "asset_list_item_24h_volume")
                                }
                            }
                            .minimumScaleFactor(0.5)
                        }

                    PlatformTableViewCellViewModel(logo: icon,
                                                   main: main.wrappedViewModel,
                                                   trailing: trailing.wrappedViewModel)
                    .createView(parentStyle: style)

                    Spacer()
                }
            )
        }
    }
}

#if DEBUG
struct dydxClosePositionHeaderView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxClosePositionHeaderViewModel.previewValue
            .createView()
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxClosePositionHeaderView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxClosePositionHeaderViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
