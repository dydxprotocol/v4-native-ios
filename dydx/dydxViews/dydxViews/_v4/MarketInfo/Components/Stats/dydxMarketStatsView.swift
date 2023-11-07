//
//  dydxMarketStatsView.swift
//  dydxViews
//
//  Created by Rui Huang on 10/11/22.
//  Copyright © 2022 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxMarketStatsViewModel: PlatformViewModel {
    public struct StatItem: Hashable {
        public static func == (lhs: dydxMarketStatsViewModel.StatItem, rhs: dydxMarketStatsViewModel.StatItem) -> Bool {
            lhs.header == rhs.header && lhs.token == rhs.token
        }

        public func hash(into hasher: inout Hasher) {
            hasher.combine(header)
            hasher.combine(token)
        }

        public init(header: String, value: PlatformViewModel, token: TokenTextViewModel? = nil) {
            self.header = header
            self.value = value
            self.token = token
        }

        let header: String
        let value: PlatformViewModel
        let token: TokenTextViewModel?
    }

    @Published public var statItems: [StatItem] = []

    public init() { }

    public static var previewValue: dydxMarketStatsViewModel = {
        let vm = dydxMarketStatsViewModel()
        vm.statItems = [
            .init(header: "Index Price", value: SignedAmountViewModel.previewValue),
            .init(header: "Oracle Price", value: SignedAmountViewModel.previewValue),
            .init(header: "12h Volume", value: SignedAmountViewModel.previewValue, token: .previewValue)
        ]
        return vm
    }()

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let itemPerRow = 2

            return AnyView(
                VStack(spacing: 0) {
                    DividerModel().createView(parentStyle: style)

                    ForEach(0..<self.statItems.count / itemPerRow + 1, id: \.self) { row in
                        if row * itemPerRow < self.statItems.count {
                            HStack(spacing: 0) {
                                ForEach(0..<itemPerRow, id: \.self) { col in
                                    let itemIdx = row * itemPerRow + col
                                    if itemIdx < self.statItems.count {
                                        let item = self.statItems[itemIdx]
                                        VStack {
                                            HStack {
                                                Text(item.header)
                                                    .themeFont(fontSize: .smaller)
                                                    .themeColor(foreground: .textTertiary)
                                                Spacer()
                                            }
                                            Spacer()
                                            HStack {
                                                item.value
                                                    .createView(parentStyle: style)
                                                item.token?
                                                    .createView(parentStyle: style.themeFont(fontSize: .smaller))

                                                Spacer()
                                            }
                                            .minimumScaleFactor(0.5)
                                        }
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 16)
                                        .frame(maxWidth: .infinity)
                                    } else {
                                        PlatformView.emptyView
                                            .themeColor(background: .layer0)
                                            .frame(maxWidth: .infinity)
                                    }

                                    if col < itemPerRow - 1 {
                                        DividerModel()
                                            .createView(parentStyle: style)
                                            .frame(maxHeight: .infinity)
                                    }
                                }
                            }
                            .frame(height: 78)

                            DividerModel().createView(parentStyle: style)
                        }
                    }
                }
            )
        }
    }
}

#if DEBUG
struct dydxMarketStatsView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxMarketStatsViewModel.previewValue
            .createView()
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxMarketStatsView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxMarketStatsViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
