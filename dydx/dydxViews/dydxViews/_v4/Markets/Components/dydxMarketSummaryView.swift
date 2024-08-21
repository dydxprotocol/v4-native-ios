//
//  dydxMarketSummaryView.swift
//  dydxViews
//
//  Created by Rui Huang on 9/29/22.
//  Copyright © 2022 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxMarketSummaryViewModel: PlatformViewModel {
    public struct SummaryItem: Hashable, Equatable {
        public init(header: String, value: String) {
            self.header = header
            self.value = value
        }

        let header: String
        let value: String
    }
    @Published public var items = [SummaryItem]()

    public init() { }

    public static func == (lhs: dydxMarketSummaryViewModel, rhs: dydxMarketSummaryViewModel) -> Bool {
        lhs.items == rhs.items
    }

    public static var previewValue: dydxMarketSummaryViewModel = {
        let vm = dydxMarketSummaryViewModel()
        vm.items = [
            SummaryItem(header: "24h Volume", value: "$1.00M"),
            SummaryItem(header: "Open Interest", value: "$133.00K"),
            SummaryItem(header: "Trades", value: "1,245")
        ]
       return vm
    }()

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            return AnyView(
                HStack {
                    ForEach(self.items, id: \.header) { item in
                        VStack(alignment: .leading) {
                            Text(item.header)
                                .themeFont(fontSize: .smaller)
                                .themeColor(foreground: .textTertiary)
                            Text(item.value)
                                .animation(.none, value: UUID())
                        }
                        if item != self.items.last {
                            Spacer()
                            DividerModel().createView(parentStyle: style)
                            Spacer()
                        }
                    }
                }
                .padding([.top, .bottom], 8)
            )
        }
    }
}

#if DEBUG
struct dydxMarketSummaryView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxMarketSummaryViewModel.previewValue
            .createView()
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxMarketSummaryView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxMarketSummaryViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
