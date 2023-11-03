//
//  dydxReceiptRewardsView.swift
//  dydxUI
//
//  Created by Rui Huang on 9/22/23.
//  Copyright © 2023 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxReceiptRewardsViewModel: PlatformViewModel {
    @Published public var rewards: SignedAmountViewModel?
    @Published public var nativeTokenLogoUrl: URL?

    public init() { }

    public static var previewValue: dydxReceiptRewardsViewModel {
        let vm = dydxReceiptRewardsViewModel()
        vm.rewards = .previewValue
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            return AnyView(
                HStack(spacing: 4) {
                    Text(DataLocalizer.localize(path: "APP.GENERAL.MAXIMUM_REWARDS"))
                        .themeFont(fontSize: .small)
                        .themeColor(foreground: .textTertiary)
                        .lineLimit(1)
                    if let nativeTokenLogoUrl = self.nativeTokenLogoUrl {
                        PlatformIconViewModel(type: .url(url: nativeTokenLogoUrl),
                                              size: CGSize(width: 18, height: 18))
                        .createView(parentStyle: style)
                    }

                    Spacer()
                    if let rewards = self.rewards {
                        rewards.createView(parentStyle: style
                            .themeFont(fontType: .number, fontSize: .small)
                            .themeColor(foreground: .textPrimary))
                            .lineLimit(1)
                    } else {
                        dydxReceiptEmptyView.emptyValue
                    }
                }
            )
        }
    }
}

#if DEBUG
struct dydxReceiptRewardsView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxReceiptRewardsViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxReceiptRewardsView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxReceiptRewardsViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
