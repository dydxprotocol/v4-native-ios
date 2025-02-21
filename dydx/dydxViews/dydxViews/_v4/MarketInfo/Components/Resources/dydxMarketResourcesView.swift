//
//  dydxMarketResourcesView.swift
//  dydxViews
//
//  Created by Rui Huang on 10/12/22.
//  Copyright © 2022 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxMarketResourcesViewModel: PlatformViewModel {
    @Published public var sharedMarketViewModel: SharedMarketViewModel? = SharedMarketViewModel()

    public init() { }

    public static var previewValue: dydxMarketResourcesViewModel = {
        let vm = dydxMarketResourcesViewModel()
        vm.sharedMarketViewModel = .previewValue
        return vm
    }()

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self, let sharedMarketViewModel = self.sharedMarketViewModel else {
                return AnyView(PlatformView.nilView)
            }

            func createIconButton(url: URL?, iconAssetName: String) -> AnyView {
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

            return AnyView(
                VStack(alignment: .leading, spacing: 8) {

                    let icon = PlatformIconViewModel(type: .url(url: sharedMarketViewModel.logoUrl),
                                                     clip: .defaultCircle,
                                                     size: CGSize(width: 40, height: 40),
                                                     backgroundColor: .colorWhite)

                    let main =
                        HStack {
                            VStack(alignment: .leading) {
                                HStack(spacing: 4) {
                                    Text(sharedMarketViewModel.assetName ?? "")
                                        .themeColor(foreground: .textPrimary)
                                        .themeFont(fontType: .plus, fontSize: .medium)
                                }
                                Text(sharedMarketViewModel.assetId ?? "")
                                    .themeFont(fontType: .base, fontSize: .small)
                            }
                            Spacer()
                        }

                    let trailing =
                        HStack {
                            createIconButton(url: sharedMarketViewModel.coinMarketPlaceUrl, iconAssetName: "icon_coinmarketcap")
                            createIconButton(url: sharedMarketViewModel.whitepaperUrl, iconAssetName: "icon_whitepaper")
                            createIconButton(url: sharedMarketViewModel.websiteUrl, iconAssetName: "icon_web")
                        }

                    PlatformTableViewCellViewModel(logo: icon,
                                                   main: main.wrappedViewModel,
                                                   trailing: trailing.wrappedViewModel)
                        .createView(parentStyle: style)

                    Group {
                        if let primaryDescription = sharedMarketViewModel.primaryDescription {
                            Text(primaryDescription)
                        }
                        if let secondaryDescription = sharedMarketViewModel.secondaryDescription {
                            Text(secondaryDescription)
                        }
                    }
                        .themeFont(fontSize: .medium)
                        .themeColor(foreground: .textSecondary)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                }
            )
        }
    }
}

#if DEBUG
struct dydxMarketResourcesView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxMarketResourcesViewModel.previewValue
            .createView()
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxMarketResourcesView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxMarketResourcesViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
