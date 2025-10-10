//
//  dydxRewardsLaunchIncentivesView.swift
//  dydxUI
//
//  Created by Michael Maguire on 12/11/23.
//  Copyright © 2023 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxRewardsLaunchIncentivesViewModel: PlatformViewModel {
    @Published public var seasonOrdinal: String?
    @Published public var points: String?
    @Published public var aboutAction: (() -> Void)?
    @Published public var leaderboardAction: (() -> Void)?
    @Published public var isSep2025: Bool = false
    @Published public var rewardsAmount: String?
    @Published public var rewardsRebate: String?

    public static var previewValue: dydxRewardsLaunchIncentivesViewModel = {
        let vm = dydxRewardsLaunchIncentivesViewModel()
        vm.seasonOrdinal = "1"
        return vm
    }()

    private lazy var launchIncentivesFormatted: AttributedString = {
        let launchIncentives: String?
        if isSep2025 {
            launchIncentives = DataLocalizer.localize(path: "APP.REWARDS_SURGE_APRIL_2025.SURGE") + ": " +
            DataLocalizer.localize(path: "APP.REWARDS_SURGE_APRIL_2025.SURGE_HEADLINE_SEP_2025",
                                                      params: [
                                                        "REWARD_AMOUNT": rewardsAmount ?? "-",
                                                        "REBATE_PERCENT": rewardsRebate ?? "-"
                                                      ])
        } else {
            launchIncentives = DataLocalizer.localize(path: "APP.REWARDS_SURGE_APRIL_2025.SURGE_HEADLINE", params: nil)
        }
        guard let launchIncentives else { return .init() }

        return AttributedString(launchIncentives)
            .themeFont(fontType: .base, fontSize: .medium)
            .themeColor(foreground: .textPrimary)
    }()

    private var pointsFormatted: AttributedString {
        guard let points = points else { return .init() }
        let localizedString = DataLocalizer.shared?.localize(path: "APP.TRADING_REWARDS.POINTS", params: ["POINTS": points]) ?? ""

        var attributedString = AttributedString(localizedString)
            .themeFont(fontType: .base, fontSize: .largest)

        attributedString = attributedString.themeColor(foreground: .textTertiary, to: nil)
        if let pointsTextRange = attributedString.range(of: points) {
            attributedString = attributedString.themeColor(foreground: .textPrimary, to: pointsTextRange)
        }

        return attributedString
    }

    private func createEstimateSubCard() -> some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 52) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(DataLocalizer.shared?.localize(path: "APP.TRADING_REWARDS.ESTIMATED_POINTS", params: nil) ?? "")
                        .themeFont(fontType: .base, fontSize: .medium)
                        .themeColor(foreground: .textPrimary)

                    Text(DataLocalizer.shared?.localize(path: "APP.TRADING_REWARDS.TOTAL_POINTS", params: nil) ?? "")
                        .themeFont(fontType: .base, fontSize: .small)
                        .themeColor(foreground: .textTertiary)
                }
                Text(pointsFormatted)
            }
            Spacer()
            Image("stars", bundle: .dydxView)
        }
        .padding(.all, 16)
        .background {
            Image(themedImageBaseName: "texture", bundle: .dydxView)
                .resizable()
                .scaledToFill()
        }
        .themeColor(background: .layer4)
        .borderAndClip(style: .cornerRadius(12), borderColor: .layer6, lineWidth: 1)
    }

    private func createAboutButton(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        let content = PlatformViewModel { style in
            HStack(spacing: 8) {
                Text(DataLocalizer.shared?.localize(path: "APP.TRADING_REWARDS.ABOUT", params: nil) ?? "")
                    .themeFont(fontType: .base, fontSize: .small)
                    .themeStyle(style: style)
                PlatformIconViewModel(type: .asset(name: "icon_link", bundle: .dydxView), size: .init(width: 12, height: 12))
                    .createView(parentStyle: parentStyle)
            }
            .wrappedInAnyView()
        }
        return PlatformButtonViewModel(content: content, type: .defaultType(fillWidth: true), state: .secondary, action: self.aboutAction ?? {})
            .createView(parentStyle: parentStyle)
    }

    private func createLeaderboardButton(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        let content = PlatformViewModel { style in
           HStack(spacing: 8) {
               PlatformIconViewModel(type: .asset(name: "icon_leaderboard", bundle: .dydxView), size: .init(width: 12, height: 12))
                   .createView(parentStyle: parentStyle)
                Text(DataLocalizer.shared?.localize(path: "APP.TRADING_REWARDS.LEADERBOARD", params: nil) ?? "")
                    .themeFont(fontType: .base, fontSize: .small)
                    .themeStyle(style: style)
            }
            .wrappedInAnyView()
        }
        return PlatformButtonViewModel(content: content, type: .defaultType(fillWidth: true), state: .primary, action: self.leaderboardAction ?? {})
            .createView(parentStyle: parentStyle)
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let body: String
            if self.isSep2025 {
                body = DataLocalizer.localize(path: "APP.REWARDS_SURGE_APRIL_2025.SURGE_BODY_SEP_2025",
                                              params: [
                                                "REWARD_AMOUNT": "$1M",
                                                "REBATE_PERCENT": "50%"
                                              ])
            } else {
                body = DataLocalizer.localize(path: "APP.REWARDS_SURGE_APRIL_2025.SURGE_BODY", params: nil)
            }

            return VStack(spacing: 16) {
                self.createEstimateSubCard()
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .center) {
                        Text(self.launchIncentivesFormatted)

                        Text(DataLocalizer.localize(path: "APP.GENERAL.ACTIVE"))
                            .themeColor(foreground: .colorGreen)
                            .themeFont(fontType: .base, fontSize: .smaller)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 4)
                            .border(borderWidth: 1, cornerRadius: 4, borderColor: ThemeColor.SemanticColor.colorGreen.color)

                        Spacer()
                    }

                    Text(body)
                        .themeFont(fontType: .base, fontSize: .small)
                        .themeColor(foreground: .textTertiary)

                    HStack(spacing: 8) {
                        Text(DataLocalizer.shared?.localize(path: "APP.TRADING_REWARDS.POWERED_BY", params: nil) ?? "")
                            .themeFont(fontType: .base, fontSize: .smaller)
                            .themeColor(foreground: .textSecondary)
                        Image("icon_chaos_labs", bundle: .dydxView)
                        Image("text_chaos_labs", bundle: .dydxView)
                            .templateColor(.textPrimary)
                    }
                }
                HStack(spacing: 10) {
                    self.createAboutButton(parentStyle: style)
                        .fixedSize()
                    self.createLeaderboardButton(parentStyle: style)
                }
            }
            .padding(.all, 16)
            .themeColor(background: .layer3)
            .cornerRadius(12, corners: .allCorners)
            .wrappedInAnyView()
        }
    }
}

#if DEBUG
struct dydxRewardsLaunchIncentivesView_Previews: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        Group {
            dydxRewardsLaunchIncentivesViewModel.previewValue
                .createView()
                .environmentObject(themeSettings)
                .previewLayout(.sizeThatFits)
        }
    }
}
#endif
