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
    @Published public var rewardsSummary: dydxRewardsSummaryViewModel = dydxRewardsSummaryViewModel()

    public init() { }

    public static var previewValue: dydxHelpViewModel {
        let vm = dydxHelpViewModel()
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }
            return VStack(spacing: 24) {
                ScrollView(showsIndicators: false) {
                    self.headerViewModel.createView(parentStyle: parentStyle)
                    self.rewardsSummary.createView(parentStyle: style)
                    Spacer(minLength: 68)
                }
                .padding()
            }
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
            .themeColor(background: .layer0)
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
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
