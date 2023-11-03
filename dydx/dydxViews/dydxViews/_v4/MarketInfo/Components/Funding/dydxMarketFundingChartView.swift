//
//  dydxMarketFundingChartView.swift
//  dydxViews
//
//  Created by Rui Huang on 10/11/22.
//  Copyright © 2022 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxMarketFundingChartViewModel: PlatformViewModel {
    @Published public var chart: dydxChartViewModel?
    @Published public var title: String?
    @Published public var subtitle: ColoredTextModel?
    @Published public var durationControl: dydxMarketFundingDurationsViewModel? = dydxMarketFundingDurationsViewModel()

    public init() { }

    public static var previewValue: dydxMarketFundingChartViewModel = {
        let vm = dydxMarketFundingChartViewModel()
        vm.durationControl = .previewValue
        vm.title = "title"
        vm.subtitle = .previewValue
        vm.chart = .previewValue
        return vm
    }()

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            return AnyView(
                VStack(spacing: 8) {
                    HStack {
                        self.durationControl?.createView(parentStyle: style)
                        Spacer()
                    }
                    .padding(.horizontal, 16)

                    VStack {
                        if let title = self.title {
                            Text(title)
                                .themeFont(fontSize: .medium)
                        }
                        self.subtitle?.createView(parentStyle: style.themeFont(fontType: .number, fontSize: .medium))
                    }
                    self.chart?.createView(parentStyle: style)
                        .frame(height: 204)
                }
            )
        }
    }
}

#if DEBUG
struct dydxMarketFundingChartView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxMarketFundingChartViewModel.previewValue
            .createView()
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxMarketFundingChartView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxMarketFundingChartViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
