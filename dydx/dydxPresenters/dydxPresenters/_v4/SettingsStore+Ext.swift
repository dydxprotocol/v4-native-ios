//
//  SettingsStore+Ext.swift
//  dydxPresenters
//
//  Created by Michael Maguire on 3/28/24.
//

import Foundation
import Utilities
import dydxViews

extension SettingsStore {

    private enum Key: String {
        case language = "language"
        case v4Theme = "v4_theme"
        case directionColorPreference = "direction_color_preference"
        case shouldDisplayInAppNotifications = "should_display_in_app_notifications"
    }

    static var language: Bool {
        SettingsStore.shared?.value(forKey: Key.language.rawValue) as? Bool
        ?? SettingsStore.defaultValues[.language] as? Bool
        ?? true
    }

    static var v4Theme: Bool {
        SettingsStore.shared?.value(forKey: Key.v4Theme.rawValue) as? Bool
        ?? SettingsStore.defaultValues[.v4Theme] as? Bool
        ?? true
    }

    static var directionColorPreference: Bool {
        SettingsStore.shared?.value(forKey: Key.directionColorPreference.rawValue) as? Bool
        ?? SettingsStore.defaultValues[.directionColorPreference] as? Bool
        ?? true
    }

    static var shouldDisplayInAppNotifications: Bool {
        SettingsStore.shared?.value(forKey: Key.shouldDisplayInAppNotifications.rawValue) as? Bool
        ?? SettingsStore.defaultValues[.shouldDisplayInAppNotifications] as? Bool
        ?? true
    }

    private static let defaultValues: [Key: Any?] = [
        .language: DataLocalizer.shared?.language,
        .v4Theme: dydxThemeType.dark.rawValue,
        // whether green or red is the positive direction
        .directionColorPreference: "green_is_up",
        .shouldDisplayInAppNotifications: true
    ]
}
