//
//  dydxSimpleUIMarketCandlesView.swift
//  dydxUI
//
//  Created by Rui Huang on 26/12/2024.
//  Copyright © 2024 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxSimpleUIMarketCandlesViewModel: PlatformViewModel {
    @Published public var chart: dydxChartViewModel?
    @Published public var resolutions = dydxSimpleUIMarketCandlesResolutionsViewModel()
    @Published public var highlight: dydxSimpleUIMarketCandlesHighlightViewModel?
    @Published public var highlightX: CGFloat? = 0
    @Published public var highlightY: CGFloat? = 0

    public let height: CGFloat = 224

    public init() { }

    public static var previewValue: dydxSimpleUIMarketCandlesViewModel {
        let vm = dydxSimpleUIMarketCandlesViewModel()
        vm.chart = .previewValue
        vm.highlight = .previewValue
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let view = VStack(alignment: .leading, spacing: 8) {
                ZStack {
                    self.chart?.createView(parentStyle: style)
                        .frame(height: self.height)

                    if let highlight = self.highlight,
                       let highlightX = self.highlightX,
                       let highlightY = self.highlightY {
                        let x = highlight.width / 2
                        let y = highlight.height / 2
                        highlight.createView(parentStyle: style)
                            .position(x: x + highlightX, y: y + highlightY)
                    }
                }
                .frame(height: self.height)

                self.resolutions.createView(parentStyle: style)
            }
            return AnyView(view)
        }
    }
}

#if DEBUG
struct dydxSimpleUIMarketCandlesView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxSimpleUIMarketCandlesViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxSimpleUIMarketCandlesView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxSimpleUIMarketCandlesViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
