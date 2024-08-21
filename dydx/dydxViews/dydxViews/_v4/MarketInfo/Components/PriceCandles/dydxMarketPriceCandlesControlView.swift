//
//  dydxMarketPriceCandlesControlView.swift
//  dydxViews
//
//  Created by Rui Huang on 10/7/22.
//  Copyright © 2022 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxMarketPriceCandlesControlViewModel: PlatformViewModel {
    @Published public var types = dydxMarketPriceCandlesTypesViewModel()
    @Published public var resolutions = dydxMarketPriceCandlesResolutionsViewModel()

    public init() { }

    public init(types: dydxMarketPriceCandlesTypesViewModel = dydxMarketPriceCandlesTypesViewModel(), resolutions: dydxMarketPriceCandlesResolutionsViewModel = dydxMarketPriceCandlesResolutionsViewModel()) {
        self.types = types
        self.resolutions = resolutions
    }

    public static var previewValue: dydxMarketPriceCandlesControlViewModel = {
        let vm = dydxMarketPriceCandlesControlViewModel()
        vm.types = dydxMarketPriceCandlesTypesViewModel.previewValue
        vm.resolutions = dydxMarketPriceCandlesResolutionsViewModel.previewValue
        return vm
    }()

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            return AnyView(
                HStack {
                    self.types.createView(parentStyle: style)
                    Spacer()
                    self.resolutions.createView(parentStyle: style)
                }
            )
        }
    }
}

#if DEBUG
struct dydxMarketInfoCandlesResolutionView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxMarketPriceCandlesControlViewModel.previewValue
            .createView()
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxMarketInfoCandlesResolutionView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxMarketPriceCandlesControlViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
