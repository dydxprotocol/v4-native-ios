//
//  dydxMarketDepthView.swift
//  dydxViews
//
//  Created by Rui Huang on 10/10/22.
//  Copyright © 2022 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxMarketDepthChartViewModel: PlatformViewModel {
    @Published public var chart: dydxChartViewModel?
    @Published public var hightlight: dydxMarketDepthHightlightViewModel?
    @Published public var hightlightX: CGFloat? = 0
    @Published public var hightlightY: CGFloat? = 0

    public let height: CGFloat = 280

    public init() { }

    public static var previewValue: dydxMarketDepthChartViewModel = {
        let vm = dydxMarketDepthChartViewModel()
        vm.chart = .previewValue
        vm.hightlight = .previewValue
        return vm
    }()

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            return AnyView(
                ZStack {
                    self.chart?.createView(parentStyle: style)
                        .frame(height: self.height)

                    if let hightlight = self.hightlight,
                       let hightlightX = self.hightlightX,
                       let hightlightY = self.hightlightY {
                        let x = hightlight.width / 2
                        let y = hightlight.height / 2
                        hightlight.createView(parentStyle: style)
                            .position(x: x + hightlightX, y: y + hightlightY)
                    }
                }
                .frame(height: self.height)
            )
        }
    }
}

#if DEBUG
struct dydxMarketDepthView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxMarketDepthChartViewModel.previewValue
            .createView()
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxMarketDepthView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxMarketDepthChartViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
