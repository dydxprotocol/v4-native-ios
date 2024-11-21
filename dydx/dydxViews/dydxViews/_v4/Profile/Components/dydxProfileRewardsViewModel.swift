//
//  dydxProfileRewardsViewModel.swift
//  dydxUI
//
//  Created by Rui Huang on 9/18/23.
//  Copyright © 2023 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxProfileRewardsViewModel: dydxTitledCardViewModel {
    @Published public var last7DaysRewardsAmount: String?
    @Published public var allTimeRewardsAmount: String?

    public init() {
        super.init(title: DataLocalizer.shared?.localize(path: "APP.GENERAL.TRADING_REWARDS", params: nil) ?? "")
    }

    override func createContentView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> AnyView? {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 10) {
                titleValueStack(title: DataLocalizer.shared?.localize(path: "APP.GENERAL.TIME_STRINGS.THIS_WEEK", params: nil) ?? "", value: last7DaysRewardsAmount)
                if let allTimeRewardsAmount = allTimeRewardsAmount {
                    titleValueStack(title: DataLocalizer.shared?.localize(path: "APP.GENERAL.TIME_STRINGS.ALL_TIME", params: nil) ?? "", value: allTimeRewardsAmount)
                }
            }
            Spacer()
        }
        .wrappedInAnyView()
    }

    private func titleValueStack(title: String, value: String?) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .themeColor(foreground: .textSecondary)
                .themeFont(fontType: .base, fontSize: .smaller)
            HStack(spacing: 6) {
                Text(value ?? "-")
                    .themeColor(foreground: .textPrimary)
                    .themeFont(fontType: .base, fontSize: .small)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                PlatformIconViewModel(type: .asset(name: "icon_dydx", bundle: .dydxView), clip: .noClip, size: .init(width: 24, height: 24), templateColor: nil)
                    .createView()
            }
        }

    }

    public static var previewValue: dydxProfileRewardsViewModel {
        let vm = dydxProfileRewardsViewModel()
        vm.last7DaysRewardsAmount = "20.00"
        vm.allTimeRewardsAmount = "30.00"
        return vm
    }

}

#if DEBUG
struct dydxProfileRewardsViewModel_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxProfileRewardsViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxProfileRewardsViewModel_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxProfileRewardsViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
