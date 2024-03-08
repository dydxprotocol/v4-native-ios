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

    public static var previewValue: dydxRewardsLaunchIncentivesViewModel = {
        let vm = dydxRewardsLaunchIncentivesViewModel()
        vm.seasonOrdinal = "1"
        return vm
    }()

    private let launchIncentivesFormatted: AttributedString = {
        guard let launchIncentives = DataLocalizer.shared?.localize(path: "APP.TRADING_REWARDS.LAUNCH_INCENTIVES", params: nil) else { return .init() }
        let localizedString = DataLocalizer.shared?.localize(path: "APP.TRADING_REWARDS.FOR_V4", params: ["SUBJECT": launchIncentives]) ?? ""

        var attributedString = AttributedString(localizedString)
            .themeFont(fontType: .text, fontSize: .medium)

        attributedString = attributedString.themeColor(foreground: .textTertiary, to: nil)
        if let launchIncentivesRange = attributedString.range(of: launchIncentives) {
            attributedString = attributedString.themeColor(foreground: .textPrimary, to: launchIncentivesRange)
        }

        return attributedString
    }()

    private var pointsFormatted: AttributedString {
        guard let points = points else { return .init() }
        let localizedString = DataLocalizer.shared?.localize(path: "APP.TRADING_REWARDS.POINTS", params: ["POINTS": points]) ?? ""

        var attributedString = AttributedString(localizedString)
            .themeFont(fontType: .text, fontSize: .largest)

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
                    Text(DataLocalizer.shared?.localize(path: "APP.PORTFOLIO.ESTIMATED_REWARDS", params: nil) ?? "")
                        .themeFont(fontType: .text, fontSize: .medium)
                        .themeColor(foreground: .textPrimary)
                    if let seasonOrdinal {
                        Text(DataLocalizer.shared?.localize(path: "APP.TRADING_REWARDS.SEASON_ID", params: ["SEASON_ID": seasonOrdinal]) ?? "")
                            .themeFont(fontType: .text, fontSize: .small)
                            .themeColor(foreground: .textPrimary)
                    }
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
                    .themeFont(fontType: .text, fontSize: .small)
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
                    .themeFont(fontType: .text, fontSize: .small)
                    .themeStyle(style: style)
            }
            .wrappedInAnyView()
        }
        return PlatformButtonViewModel(content: content, type: .defaultType(fillWidth: true), state: .primary, action: self.leaderboardAction ?? {})
            .createView(parentStyle: parentStyle)
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] _  in
            guard let self = self else { return AnyView(PlatformView.nilView) }
            return VStack(spacing: 16) {
                self.createEstimateSubCard()
                VStack(alignment: .leading, spacing: 8) {
                    Text(self.launchIncentivesFormatted)
                    Text(DataLocalizer.shared?.localize(path: "APP.TRADING_REWARDS.LAUNCH_INCENTIVES_DESCRIPTION", params: nil) ?? "")
                        .themeFont(fontType: .text, fontSize: .small)
                        .themeColor(foreground: .textTertiary)
                    HStack(spacing: 8) {
                        Text(DataLocalizer.shared?.localize(path: "APP.TRADING_REWARDS.POWERED_BY", params: nil) ?? "")
                            .themeFont(fontType: .text, fontSize: .smaller)
                            .themeColor(foreground: .textSecondary)
                        Image("icon_chaos_labs", bundle: .dydxView)
                        Image("text_chaos_labs", bundle: .dydxView)
                            .templateColor(.textPrimary)
                    }
                }
                HStack(spacing: 10) {
                    self.createAboutButton(parentStyle: parentStyle)
                        .fixedSize()
                    self.createLeaderboardButton(parentStyle: parentStyle)
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
