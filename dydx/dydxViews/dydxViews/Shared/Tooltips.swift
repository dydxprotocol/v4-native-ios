//
//  Tooltips.swift
//  dydxViews
//
//  Created by Rui Huang on 12/02/2025.
//

import SwiftUI
import dydxFormatter
import Utilities
import PlatformUI

enum Tooltips {
    static func buyingPower(learnMoreAction: (() -> Void)?) -> TooltipModel {
        let tooltip = TooltipModel()
        let attributedTitle = AttributedString(DataLocalizer.localize(path: "APP.GENERAL.BUYING_POWER"))
            .themeFont(fontSize: .small)
            .themeColor(foreground: .textTertiary)
        tooltip.label = Text(attributedTitle.dottedUnderline(foreground: .textTertiary))
            .themeColor(foreground: .textTertiary)
            .wrappedViewModel
        tooltip.content = VStack(alignment: .leading, spacing: 8) {
            Text(DataLocalizer.localize(path: "APP.SIMPLE_UI.BUYING_POWER_TOOLTIP"))
                .themeFont(fontSize: .small)
                .themeColor(foreground: .textTertiary)
            Text(DataLocalizer.localize(path: "APP.GENERAL.LEARN_MORE"))
                .themeFont(fontSize: .small)
                .themeColor(foreground: ThemeColor.SemanticColor.colorPurple)
                .onTapGesture {
                    tooltip.dismiss()
                    learnMoreAction?()
                }
        }
        .wrappedViewModel
        return tooltip
    }

    static func leverage(marginUsage: Double?, learnMoreAction: (() -> Void)?) -> PlatformViewModel {
        guard let marginUsage = marginUsage else {
            return PlatformViewModel()
        }

        let tooltip = TooltipModel()
        tooltip.label = LeverageRiskModel(marginUsage: marginUsage,
                                          displayOption: .fullText(dotted: true))
        tooltip.content = VStack(alignment: .leading, spacing: 8) {
            Text(DataLocalizer.localize(path: "APP.SIMPLE_UI.RISK_TOOLTIP"))
                .themeFont(fontSize: .small)
                .themeColor(foreground: .textTertiary)
            Text(DataLocalizer.localize(path: "APP.GENERAL.LEARN_MORE"))
                .themeFont(fontSize: .small)
                .themeColor(foreground: ThemeColor.SemanticColor.colorPurple)
                .onTapGesture {
                    tooltip.dismiss()
                    learnMoreAction?()
                }
        }
        .wrappedViewModel
        return tooltip
    }
}
