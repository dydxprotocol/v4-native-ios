//
//  dydxRewardsSummaryView.swift
//  dydxViews
//
//  Created by Michael Maguire on 12/4/23.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxRewardsSummaryViewModel: dydxTitledCardViewModel {
    @Published public var last7DaysRewardsAmount: String?
    @Published public var last7DaysRewardsPeriod: String?
    @Published public var allTimeRewardsAmount: String?

    public init() {
        super.init(title: DataLocalizer.shared?.localize(path: "APP.GENERAL.TRADING_REWARDS_SUMMARY", params: nil) ?? "")
    }

    override func createContentView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> AnyView? {
        HStack(spacing: 18) {
            HStack {
                titleValueStack(title: DataLocalizer.shared?.localize(path: "APP.GENERAL.TIME_STRINGS.THIS_WEEK", params: nil) ?? "", primaryValue: last7DaysRewardsAmount, secondaryValue: last7DaysRewardsPeriod)
                if let allTimeRewardsAmount = allTimeRewardsAmount {
                    titleValueStack(title: DataLocalizer.shared?.localize(path: "APP.GENERAL.TIME_STRINGS.ALL_TIME", params: nil) ?? "", primaryValue: allTimeRewardsAmount, secondaryValue: nil)
                }
            }
        }
        .wrappedInAnyView()
    }

    override func createTitleAccessoryView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> AnyView? {
        AnyView(PlatformView.nilView)
    }

    private func titleValueStack(title: String, primaryValue: String?, secondaryValue: String?) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .themeColor(foreground: .textTertiary)
                .themeFont(fontType: .text, fontSize: .smaller)
            HStack(spacing: 6) {
                Text(primaryValue ?? "-")
                    .themeColor(foreground: .textSecondary)
                    .themeFont(fontType: .number, fontSize: .medium)
                PlatformIconViewModel(type: .asset(name: "icon_dydx", bundle: .dydxView), clip: .noClip, size: .init(width: 24, height: 24), templateColor: nil)
                    .createView()
            }
            Text(secondaryValue ?? "-")
                .themeColor(foreground: .textTertiary)
                .themeFont(fontType: .text, fontSize: .small)
        }
        .leftAligned()

    }

    public static var previewValue: dydxRewardsSummaryViewModel {
        let vm = dydxRewardsSummaryViewModel()
        vm.last7DaysRewardsAmount = "20.00"
        vm.allTimeRewardsAmount = "30.00"
        return vm
    }

}

#if DEBUG
struct dydxRewardsSummaryViewModel_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxRewardsSummaryViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxRewardsSummaryViewModel_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxRewardsSummaryViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
