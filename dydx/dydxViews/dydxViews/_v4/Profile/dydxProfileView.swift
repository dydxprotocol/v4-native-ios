//
//  dydxProfileView.swift
//  dydxViews
//
//  Created by Rui Huang on 2/7/23.
//  Copyright © 2023 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities
import dydxFormatter

public class dydxProfileViewModel: PlatformViewModel {
    @Published public var header = dydxProfileHeaderViewModel()
    @Published public var buttons = dydxProfileButtonsViewModel()
    @Published public var settingsHelp = dydxSettingsHelpRowViewModel()
    @Published public var history: dydxProfileHistoryViewModel? = dydxProfileHistoryViewModel()
    @Published public var fees: dydxProfileFeesViewModel? = dydxProfileFeesViewModel()
    @Published public var balances: dydxProfileBalancesViewModel? = dydxProfileBalancesViewModel()
    @Published public var rewards: dydxProfileRewardsViewModel? = dydxProfileRewardsViewModel()

    public init() { }

    public static var previewValue: dydxProfileViewModel {
        let vm = dydxProfileViewModel()
        vm.buttons = .previewValue
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let view = ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    self.header.createView(parentStyle: style)

                    self.buttons
                        .createView(parentStyle: style)

                    self.settingsHelp
                        .createView(parentStyle: style)
                        .padding(.top, 8)

                    self.balances?
                        .createView(parentStyle: style)

                    HStack(spacing: 14) {
                        self.fees?
                            .createView(parentStyle: style)
                        if dydxBoolFeatureFlag.enable_trading_rewards.isEnabled || true {
                            self.rewards?
                                .createView(parentStyle: style)
                        }
                    }

                    self.history?
                        .createView(parentStyle: style)

                    Spacer(minLength: 100)
                }
            }
                .padding(.horizontal)
                .themeColor(background: .layer2)
                .animation(.default)

            // make it visible under the tabbar
            return AnyView(view.ignoresSafeArea(edges: [.bottom]))
        }
    }
}

#if DEBUG
struct dydxProfileView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxProfileViewModel.previewValue
            .createView()
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxProfileView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxProfileViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
