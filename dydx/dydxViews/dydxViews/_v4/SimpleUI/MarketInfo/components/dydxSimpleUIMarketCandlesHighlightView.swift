//
//  dydxSimpleUIMarketCandlesHighlightView.swift
//  dydxUI
//
//  Created by Rui Huang on 29/04/2025.
//  Copyright © 2024 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxSimpleUIMarketCandlesHighlightViewModel: PlatformViewModel {
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

    public let width: CGFloat = 156
    public let height: CGFloat = 128

    public init() { }

    public static var previewValue: dydxSimpleUIMarketCandlesHighlightViewModel = {
        let vm = dydxSimpleUIMarketCandlesHighlightViewModel()
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

            let view =  HStack {
                Rectangle()
                    .fill(ThemeColor.SemanticColor.textTertiary.color )
                    .frame(width: 8)

                VStack(alignment: .leading, spacing: 4) {
                    Text(DataLocalizer.localize(path: "APP.GENERAL.VIEW_DATA_FOR"))
                        .themeFont(fontSize: .smallest)
                        .themeColor(foreground: .textTertiary)
                    Text(self.date ?? "")
                        .themeFont(fontSize: .smallest)
                        .themeColor(foreground: .textPrimary)

                    ForEach(self.dataPoints, id: \.self) { dataPoint in
                        HStack(spacing: 2) {
                            Text(dataPoint.prompt)
                                .themeFont(fontSize: .smallest)
                                .themeColor(foreground: .textTertiary)
                            Spacer()
                            dataPoint.amount
                                .createView(parentStyle: style
                                    .themeFont(fontType: .number, fontSize: .smallest))
                        }
                    }
                }
                .padding(8)
            }
                .themeColor(background: .layer4)
                .frame(width: self.width, height: self.height)
                .cornerRadius(8)

            return AnyView(view)
        }
    }
}

#if DEBUG
struct dydxSimpleUIMarketCandlesHighlightView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxSimpleUIMarketCandlesHighlightViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxSimpleUIMarketCandlesHighlightView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxSimpleUIMarketCandlesHighlightViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
