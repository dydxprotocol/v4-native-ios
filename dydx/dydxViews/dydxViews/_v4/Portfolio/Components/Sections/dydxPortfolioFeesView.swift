//
//  dydxPortfolioFeesView.swift
//  dydxUI
//
//  Created by Rui Huang on 8/5/23.
//  Copyright © 2023 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxPortfolioFeesItemViewModel: PlatformViewModel {
    public struct Condition: Hashable {
        public var title: String?
        public var value: String

        public init(title: String? = nil, value: String) {
            self.title = title
            self.value = value
        }
    }

    public var tier: String?
    public var conditions: [Condition] = []
    public var makerPercent: String?
    public var takerPercent: String?
    public var isUserTier: Bool = false

    public init(tier: String? = nil, conditions: [Condition] = [], makerPercent: String? = nil, takerPercent: String? = nil, isUserTier: Bool = false) {
        self.tier = tier
        self.conditions = conditions
        self.makerPercent = makerPercent
        self.takerPercent = takerPercent
        self.isUserTier = isUserTier
    }

    public static var previewValue: dydxPortfolioFeesItemViewModel {
        let item = dydxPortfolioFeesItemViewModel()
        item.tier = "1"
        item.conditions = [
            Condition(title: "Condition 1", value: "> 0"),
            Condition(title: "Condition 2", value: "> 0")
        ]
        item.makerPercent = "-0.01%"
        item.takerPercent = "-0.05%"
        item.isUserTier = true
        return item
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let view = HStack {
                HStack {
                    Text(self.tier ?? "")

                    if self.isUserTier {
                        Text(DataLocalizer.localize(path: "APP.GENERAL.YOU"))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .themeColor(background: .layer6)
                            .clipShape(Capsule())
                    }
                }
                .leftAligned()
                .frame(maxWidth: 70)

                VStack {
                    ForEach(self.conditions, id: \.self) { condition in
                        self.createCondition(parentStyle: style, condition: condition)
                            .rightAligned()
                    }
                }
                .frame(maxWidth: .infinity)

                Text(self.makerPercent ?? "")
                    .frame(width: 60)

                Text(self.takerPercent ?? "")
                    .frame(width: 60)
            }
             .themeFont(fontType: .text, fontSize: .smaller)
             .themeColor(foreground: .textPrimary)
             .padding(.horizontal, 8)
             .padding(.top, -20)

            return AnyView(view)
        }
    }

    private func createCondition(parentStyle: ThemeStyle, condition: Condition) -> some View {
        var titleString: AttributedString
        if let title = condition.title {
            titleString = AttributedString(title)
            titleString.themeFont(fontType: .text, fontSize: .smaller)
            titleString.themeColor(foreground: .textTertiary)
        } else {
            titleString = AttributedString("")
        }

        var valueString = AttributedString(condition.value)
        valueString.themeFont(fontType: .text, fontSize: .smaller)
        valueString.themeColor(foreground: .textPrimary)

        return Text(titleString + AttributedString(" ") + valueString)
                .multilineTextAlignment(.trailing)
    }
}

public class dydxPortfolioFeesListViewModel: PlatformListViewModel {
    public static var previewValue: dydxPortfolioFeesListViewModel {
        let vm = dydxPortfolioFeesListViewModel()
        vm.items = [
            dydxPortfolioFeesItemViewModel.previewValue,
            dydxPortfolioFeesItemViewModel.previewValue,
            dydxPortfolioFeesItemViewModel.previewValue
        ]
        return vm
    }

    public init() {
        super.init()
        self.placeholder = PlatformView.nilViewModel
        self.header = createHeader().wrappedViewModel
        self.width = UIScreen.main.bounds.width - 16
    }

    private func createHeader() -> some View {
        HStack {
            Text(DataLocalizer.localize(path: "APP.GENERAL.TIER"))
                .leftAligned()
                .frame(width: 70)
            Text(DataLocalizer.localize(path: "APP.GENERAL.VOLUME_30D"))
                .rightAligned()
                .frame(maxWidth: .infinity)
            Text(DataLocalizer.localize(path: "APP.TRADE.MAKER_FEE"))
                .frame(width: 65)
            Text(DataLocalizer.localize(path: "APP.TRADE.TAKER_FEE"))
                .frame(width: 65)
        }
        .padding(.horizontal, 8)
        .themeFont(fontSize: .smaller)
        .themeColor(foreground: .textTertiary)
    }
}

public class dydxPortfolioFeesViewModel: PlatformViewModel {
    public var tradingVolume: String?
    public var feeTierList = dydxPortfolioFeesListViewModel()

    public static var previewValue: dydxPortfolioFeesViewModel {
        let item = dydxPortfolioFeesViewModel()
        item.tradingVolume = "$120,000"
        item.feeTierList = .previewValue
        return item
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let view = ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    self.createStatsView(parentStyle: style)
                        .padding(.horizontal, 8)
                    self.feeTierList
                        .createView(parentStyle: style)
                    Spacer(minLength: 68)
                }
            }
            return AnyView(view)
        }
    }

    private func createStatsView(parentStyle: ThemeStyle) -> some View {
        VStack(spacing: 10) {
            HStack {
                Text(DataLocalizer.localize(path: "APP.FEE_TIERS.TRADING_VOLUME"))

                Text(DataLocalizer.localize(path: "APP.GENERAL.TIME_STRINGS.30D"))
                    .themeColor(foreground: .textTertiary)
            }
            .themeFont(fontType: .text, fontSize: .smaller)
            .leftAligned()

            Text(tradingVolume ?? "-")
                .themeFont(fontType: .text, fontSize: .small)
                .themeColor(foreground: .textPrimary)
                .leftAligned()
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .themeColor(background: .layer4)
        .cornerRadius(9, corners: .allCorners)
    }

}

#if DEBUG
struct dydxPortfolioFeesView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return  dydxPortfolioFeesViewModel.previewValue
            .createView()
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxPortfolioFeesView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxPortfolioFeesViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
