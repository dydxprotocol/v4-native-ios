//
//  dydxProfileFeesView.swift
//  dydxUI
//
//  Created by Rui Huang on 8/8/23.
//  Copyright © 2023 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxProfileFeesViewModel: dydxTitledCardViewModel, Equatable {
    public static func == (lhs: dydxProfileFeesViewModel, rhs: dydxProfileFeesViewModel) -> Bool {
        lhs.tradingVolume == rhs.tradingVolume &&
        lhs.takerFeeRate == rhs.takerFeeRate &&
        lhs.makerFeeRate == rhs.makerFeeRate
    }

    @Published public var tradingVolume: String?
    @Published public var takerFeeRate: String?
    @Published public var makerFeeRate: String?

    public init() {
        super.init(title: DataLocalizer.localize(path: "APP.GENERAL.FEES"))
    }

    fileprivate static var previewValue: dydxProfileFeesViewModel {
        let vm = dydxProfileFeesViewModel()
        vm.tradingVolume = "$120,000"
        vm.takerFeeRate = "0.01%"
        vm.makerFeeRate = "0.01%"
        return vm
    }

    override func createContentView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> AnyView? {
        VStack(spacing: 16) {
            HStack {
                VStack(spacing: 8) {
                    Text(DataLocalizer.localize(path: "APP.TRADE.TAKER"))
                        .themeFont(fontType: .base, fontSize: .smaller)

                        .leftAligned()

                    Text(self.takerFeeRate ?? "-")
                        .themeFont(fontType: .base, fontSize: .small)
                        .themeColor(foreground: .textPrimary)
                        .leftAligned()
                }

                VStack(spacing: 8) {
                    Text(DataLocalizer.localize(path: "APP.TRADE.MAKER"))
                        .themeFont(fontType: .base, fontSize: .smaller)
                        .leftAligned()

                    Text(self.makerFeeRate ?? "-")
                        .themeFont(fontType: .base, fontSize: .small)
                        .themeColor(foreground: .textPrimary)
                        .leftAligned()
                }
            }

            VStack(spacing: 8) {
                HStack {
                    Text(DataLocalizer.localize(path: "APP.TRADE.VOLUME"))

                    Text(DataLocalizer.localize(path: "APP.GENERAL.TIME_STRINGS.30D"))
                        .themeColor(foreground: .textTertiary)
                }
                .themeFont(fontType: .base, fontSize: .smaller)
                .leftAligned()

                Text(self.tradingVolume ?? "-")
                    .themeFont(fontType: .base, fontSize: .small)
                    .themeColor(foreground: .textPrimary)
                    .leftAligned()
            }
        }
        .wrappedInAnyView()
    }
}

#if DEBUG
struct dydxProfileFeesView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxProfileFeesViewModel.previewValue
            .createView()
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxProfileFeesView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxProfileFeesViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
