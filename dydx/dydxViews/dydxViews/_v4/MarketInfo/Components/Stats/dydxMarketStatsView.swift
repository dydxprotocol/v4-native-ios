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
            false // always reload
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

    @Published private var statRows = [[StatItem]]()

    @Published public var statItems: [StatItem] = [] {
        didSet {
            var newItems = [[StatItem]]()
            var currentRow = [StatItem]()
            for item in statItems {
                currentRow.append(item)
                if currentRow.count == 2 {
                    newItems.append(currentRow)
                    currentRow = []
                }
            }
            if currentRow.count > 0 {
                newItems.append(currentRow)
            }
            statRows = newItems
        }
    }

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

            return AnyView(
                VStack(spacing: 0) {
                    DividerModel().createView(parentStyle: style)

                    ForEach(self.statRows, id: \.self) { row in
                        HStack(spacing: 0) {
                            ForEach(row, id: \.self) { item in
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
                            }

                            DividerModel()
                                .createView(parentStyle: style)
                                .frame(maxHeight: .infinity)
                        }
                        .frame(height: 78)

                        DividerModel().createView(parentStyle: style)
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
