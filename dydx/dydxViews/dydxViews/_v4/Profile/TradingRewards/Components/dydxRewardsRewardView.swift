//
//  dydxRewardsRewardView.swift
//  dydxViews
//
//  Created by Michael Maguire on 12/7/23.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxRewardsRewardView: PlatformViewModel {

    public var id: String { period + amount }
    private let period: String
    private let amount: String

    public init(period: String, amount: String) {
        self.period = period
        self.amount = amount
        super.init()
    }

    private var periodFormatted: AttributedString {
        let localizedString = DataLocalizer.shared?.localize(path: "APP.TRADING_REWARDS.FOR_TRADING", params: ["PERIOD": period]) ?? ""

        var attributedString = AttributedString(localizedString)
        attributedString.themeFont(fontType: .text, fontSize: .smaller)

        attributedString.themeColor(foreground: .textTertiary, to: nil)
        if let periodTextRange = attributedString.range(of: period) {
            attributedString.themeColor(foreground: .textSecondary, to: periodTextRange)
        }

        return attributedString
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] _ in
            guard let self = self else { return AnyView(PlatformView.nilView) }
            return HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(DataLocalizer.shared?.localize(path: "APP.GENERAL.REWARDED", params: nil) ?? "")
                        .themeFont(fontType: .text, fontSize: .smaller)
                        .themeColor(foreground: .textSecondary)
                    Text(self.periodFormatted)
                }
                Spacer(minLength: 16)
                HStack(spacing: 4) {
                    Text(self.amount)
                        .themeFont(fontType: .text, fontSize: .smaller)
                        .themeColor(foreground: .textSecondary)
                    PlatformIconViewModel(type: .asset(name: "icon_dydx", bundle: .dydxView), clip: .noClip, size: .init(width: 24, height: 24), templateColor: nil)
                        .createView()
                }
            }
            .wrappedInAnyView()
        }
    }

    public static var previewValue: dydxRewardsRewardView {
        let vm = dydxRewardsRewardView(period: "test period", amount: "15")
        return vm
    }

}

#if DEBUG
struct dydxRewardsRewardView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxRewardsRewardView.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxRewardsRewardView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxRewardsRewardView.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
