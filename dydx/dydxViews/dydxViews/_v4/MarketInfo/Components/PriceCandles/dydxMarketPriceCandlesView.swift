//
//  dydxMarketPriceCandlesView.swift
//  dydxViews
//
//  Created by Rui Huang on 10/7/22.
//  Copyright © 2022 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxMarketPriceCandlesViewModel: PlatformViewModel {
    @Published public var control = dydxMarketPriceCandlesControlViewModel()
    @Published public var highlight = dydxMarketPriceCandlesHighlightViewModel()
    @Published public var chart: dydxChartViewModel?
    @Published public var isHighlighted = false

    public init() { }

    public static var previewValue: dydxMarketPriceCandlesViewModel = {
        let vm = dydxMarketPriceCandlesViewModel()
        vm.control = .previewValue
        vm.highlight = .previewValue
        vm.chart = .previewValue
        return vm
    }()

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            return AnyView(
                VStack(alignment: .leading) {
                    Group {
                        if self.isHighlighted {
                            self.highlight.createView(parentStyle: style)
                        } else {
                            self.control.createView(parentStyle: style)
                        }
                    }
                    .padding()
                    .frame(height: 60)

                    self.chart?.createView(parentStyle: style)
                        .frame(height: 224)
                }
            )
        }
    }
}

#if DEBUG
struct dydxMarketInfoCandlesView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxMarketPriceCandlesViewModel.previewValue
            .createView()
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxMarketInfoCandlesView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxMarketPriceCandlesViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
