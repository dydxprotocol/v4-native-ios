//
//  dydxMarketPriceCandlesHighlightView.swift
//  dydxViews
//
//  Created by Rui Huang on 10/9/22.
//  Copyright © 2022 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxMarketPriceCandlesHighlightViewModel: PlatformViewModel {
    public struct HighlightDataPoint: Hashable {
        let prompt: String
        let amount: SignedAmountViewModel

        public init(prompt: String, amount: SignedAmountViewModel) {
            self.prompt = prompt
            self.amount = amount
        }

        public func hash(into hasher: inout Hasher) {
            hasher.combine(prompt)
        }
    }

    @Published public var date: String?
    @Published public var dataPoints: [HighlightDataPoint] = []

    public init() { }

    public static var previewValue: dydxMarketPriceCandlesHighlightViewModel = {
        let vm = dydxMarketPriceCandlesHighlightViewModel()
        vm.date = "1/1/2001"
        vm.dataPoints = [
            HighlightDataPoint(prompt: "H", amount: .previewValue),
            HighlightDataPoint(prompt: "H", amount: .previewValue),
            HighlightDataPoint(prompt: "H", amount: .previewValue),
            HighlightDataPoint(prompt: "H", amount: .previewValue),
            HighlightDataPoint(prompt: "H", amount: .previewValue)
        ]
        return vm
    }()

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            return AnyView(
                VStack(spacing: 4) {
                    HStack {
                        Text(DataLocalizer.localize(path: "APP.GENERAL.VIEW_DATA_FOR"))
                            .themeFont(fontSize: .smallest)
                            .themeColor(foreground: .textTertiary)
                        Text(self.date ?? "")
                            .themeFont(fontSize: .smallest)
                            .themeColor(foreground: .textPrimary)
                        Spacer()
                    }
                    HStack {
                        ForEach(self.dataPoints, id: \.self) { dataPoint in
                            HStack(spacing: 2) {
                                Text(dataPoint.prompt)
                                    .themeFont(fontSize: .smallest)
                                    .themeColor(foreground: .textTertiary)

                                dataPoint.amount
                                    .createView(parentStyle: style
                                        .themeFont(fontType: .number, fontSize: .smallest))
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            )
        }
    }
}

#if DEBUG
struct dydxMarketPriceCandlesHighlightView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxMarketPriceCandlesHighlightViewModel.previewValue
            .createView()
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxMarketPriceCandlesHighlightView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxMarketPriceCandlesHighlightViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
