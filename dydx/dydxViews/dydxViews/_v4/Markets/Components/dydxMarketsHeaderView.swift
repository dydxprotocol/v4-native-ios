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

public class dydxMarketsHeaderViewModel: PlatformViewModel {
    public init(searchAction: (() -> Void)? = nil) {
        self.searchAction = searchAction
    }

    @Published var searchAction: (() -> Void)?

    public init() {}

     public static var previewValue: dydxMarketsHeaderViewModel = {
        let vm = dydxMarketsHeaderViewModel()
        return vm
    }()

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            return AnyView(
                HStack {
                    Text(DataLocalizer.localize(path: "APP.GENERAL.MARKETS", params: nil))
                        .themeFont(fontType: .plus, fontSize: .largest)
                        .themeColor(foreground: .textPrimary)

                    Spacer()

                    Text(DataLocalizer.localize(path: "APP.GENERAL.SEARCH", params: nil))
                        .themeFont(fontType: .plus, fontSize: .small)
                        .themeColor(foreground: .textTertiary)

                    PlatformButtonViewModel(content: PlatformIconViewModel(type: .asset(name: "icon_search", bundle: Bundle.dydxView),
                                                                           clip: .circle(background: .layer5, spacing: 24, borderColor: .layer6),
                                                                           size: CGSize(width: 42, height: 42)),
                                            type: .iconType,
                                            action: self.searchAction ?? {})
                        .createView(parentStyle: style)
                }
                .frame(height: 48)
            )
        }
    }
}

#if DEBUG
struct dydxMarketsHeaderView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxMarketsHeaderViewModel.previewValue.createView()
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxMarketsHeaderView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxMarketsHeaderViewModel.previewValue.createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
