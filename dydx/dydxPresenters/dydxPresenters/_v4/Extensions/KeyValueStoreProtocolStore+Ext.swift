//
//  SettingsStore+Ext.swift
//  dydxPresenters
//
//  Created by Michael Maguire on 3/28/24.
//

import Foundation
import Utilities
import dydxViews

public enum dydxSettingsStoreKey: String, CaseIterable {
    case language = "language"
    case v4Theme = "v4_theme"
    case directionColorPreference = "direction_color_preference"
    case shouldDisplayInAppNotifications = "should_display_in_app_notifications"
    case gasToken = "gas_token"
    case hidePredictionMarketsNoticeKey = "hide_prediction_markets_notice"
    case hasAcknowledgedVaultDepositTerms = "has_acknowledged_vault_deposit_terms"
    case appMode = "app_mode"

    public var defaultValue: Any? {
        switch self {
        case .language: return DataLocalizer.shared?.language
        case .v4Theme: return dydxThemeType.dark.rawValue
        case .directionColorPreference: return "green_is_up"
        case .shouldDisplayInAppNotifications: return true
        case .gasToken: return "USDC"
        case .hidePredictionMarketsNoticeKey: return false
        case .hasAcknowledgedVaultDepositTerms: return false
        case .appMode: return nil
        }
    }
}

public extension KeyValueStoreProtocol {

    var language: Bool {
        SettingsStore.shared?.value(forKey: dydxSettingsStoreKey.language.rawValue) as? Bool
        ?? dydxSettingsStoreKey.language.defaultValue as? Bool
        ?? true
    }

    var v4Theme: Bool {
        SettingsStore.shared?.value(forKey: dydxSettingsStoreKey.v4Theme.rawValue) as? Bool
        ?? dydxSettingsStoreKey.v4Theme.defaultValue as? Bool
        ?? true
    }

    var directionColorPreference: Bool {
        SettingsStore.shared?.value(forKey: dydxSettingsStoreKey.directionColorPreference.rawValue) as? Bool
        ?? dydxSettingsStoreKey.directionColorPreference.defaultValue as? Bool
        ?? true
    }

    var shouldDisplayInAppNotifications: Bool {
        SettingsStore.shared?.value(forKey: dydxSettingsStoreKey.shouldDisplayInAppNotifications.rawValue) as? Bool
        ?? dydxSettingsStoreKey.shouldDisplayInAppNotifications.defaultValue as? Bool
        ?? true
    }

    var gasToken: String? {
        SettingsStore.shared?.value(forKey: dydxSettingsStoreKey.gasToken.rawValue) as? String ?? "USDC"
    }
}
