//
//  VaultTransferType.swift
//  dydxViews
//
//  Created by Michael Maguire on 9/6/24.
//

import Utilities
import SwiftUI
import enum dydxAnalytics.AnalyticsEventV2

public enum VaultTransferType: CaseIterable, RadioButtonContentDisplayable {
    case deposit
    case withdraw

    var displayText: String {
        switch self {
        case .deposit: return DataLocalizer.localize(path: "APP.GENERAL.DEPOSIT")
        case .withdraw: return DataLocalizer.localize(path: "APP.GENERAL.WITHDRAW")
        }
    }

    var inputFieldTitle: String {
        switch self {
        case .deposit: return DataLocalizer.localize(path: "APP.VAULTS.ENTER_AMOUNT_TO_DEPOSIT")
        case .withdraw: return DataLocalizer.localize(path: "APP.VAULTS.ENTER_AMOUNT_TO_WITHDRAW")
        }
    }

    var previewTransferText: String {
        switch self {
        case .deposit: return DataLocalizer.localize(path: "APP.VAULTS.PREVIEW_DEPOSIT")
        case .withdraw: return DataLocalizer.localize(path: "APP.VAULTS.PREVIEW_WITHDRAW")
        }
    }

    var needsAmountText: String {
        switch self {
        case .deposit: return DataLocalizer.localize(path: "APP.VAULTS.ENTER_AMOUNT_TO_DEPOSIT")
        case .withdraw: return DataLocalizer.localize(path: "APP.VAULTS.ENTER_AMOUNT_TO_WITHDRAW")
        }
    }

    var confirmTransferText: String {
        switch self {
        case .deposit: return DataLocalizer.localize(path: "APP.VAULTS.CONFIRM_DEPOSIT_CTA")
        case .withdraw: return DataLocalizer.localize(path: "APP.VAULTS.CONFIRM_WITHDRAW_CTA")
        }
    }

    var transferOriginTitleText: String {
        switch self {
        case .deposit: return DataLocalizer.localize(path: "APP.VAULTS.AMOUNT_TO_DEPOSIT")
        case .withdraw: return DataLocalizer.localize(path: "APP.VAULTS.AMOUNT_TO_WITHDRAW")
        }
    }

    var transferOriginImage: Image {
        Image("symbol_USDC", bundle: .dydxView)
    }

    var transferDestinationImage: Image? {
        switch self {
        case .deposit: return Image("icon_chain", bundle: .dydxView)
        case .withdraw: return nil
        }
    }

    var transferDestinationTitleText: String {
        DataLocalizer.localize(path: "APP.GENERAL.DESTINATION")
    }

    var transferDestinationSubtitleText: String {
        switch self {
        case .deposit: return DataLocalizer.localize(path: "APP.VAULTS.MEGAVAULT")
        case .withdraw: return DataLocalizer.localize(path: "APP.VAULTS.CROSS_ACCOUNT")
        }
    }

    public var analyticsInputType: AnalyticsEventV2.VaultAnalyticsInputType {
        switch self {
        case .deposit: return .deposit
        case .withdraw: return .withdraw
        }
    }
}
