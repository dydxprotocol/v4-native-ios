//
//  dydxTradingRewardsView.swift
//  dydxViews
//
//  Created by Michael Maguire on 12/4/23.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxTradingRewardsViewModel: PlatformViewModel {

    @Published public var headerViewModel: NavHeaderModel = NavHeaderModel()
    @Published public var launchIncentivesViewModel: dydxRewardsLaunchIncentivesViewModel? = dydxRewardsLaunchIncentivesViewModel()
    @Published public var rewardsSummary: dydxRewardsSummaryViewModel? = dydxRewardsSummaryViewModel()
    @Published public var help: dydxRewardsHelpViewModel? = dydxRewardsHelpViewModel()
    @Published public var history: dydxRewardsHistoryViewModel? = dydxRewardsHistoryViewModel()
    // removed as part of https://linear.app/dydx/issue/TRCL-3445/remove-governance-and-staking-cards
    // non-zero chance we add back
    // these vars and their corresponding files can be fully deleted if rewards is no longer relevant
//    @Published public var governanceViewModel: dydxRewardsLearnMoreViewModel?
//    @Published public var stakingViewModel: dydxRewardsLearnMoreViewModel?

    public init() { }

    public static var previewValue: dydxHelpViewModel {
        let vm = dydxHelpViewModel()
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }
            return VStack(spacing: 8) {
                self.headerViewModel.createView(parentStyle: parentStyle)
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        self.launchIncentivesViewModel?.createView(parentStyle: style)
                        self.rewardsSummary?.createView(parentStyle: style)
                        self.help?.createView(parentStyle: style)
                        self.history?.createView(parentStyle: style)
                        // see comment near top
//                        self.governanceViewModel?.createView(parentStyle: style)
//                        self.stakingViewModel?.createView(parentStyle: style)
                        Spacer(minLength: 80)
                    }
                }
            }
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity)
            .themeColor(background: .layer2)
            .ignoresSafeArea(edges: [.bottom])
            .wrappedInAnyView()
        }
    }
}

#if DEBUG
struct dydxTradingRewardsViewModel_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxHelpViewModel.previewValue
            .createView()
            .environmentObject(themeSettings)
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxTradingRewardsViewModel_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxHelpViewModel.previewValue
            .createView()
            .environmentObject(themeSettings)
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
