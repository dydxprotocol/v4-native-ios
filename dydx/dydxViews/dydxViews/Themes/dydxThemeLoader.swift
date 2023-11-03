//
//  dydxThemeLoader.swift
//  dydxViews
//
//  Created by Rui Huang on 4/27/23.
//

import Utilities
import PlatformUI

public struct dydxThemeLoader {

    public static var settingsTheme: dydxThemeType {
        if let themeRaw = SettingsStore.shared?.value(forKey: "v4_theme") as? String,
           let theme = dydxThemeType(rawValue: themeRaw) {
            return theme
        }
        return ThemeSettings.defaultTheme
    }

    public static func updateTheme() {
        ThemeSettings.respondsToSystemTheme = Self.settingsTheme == .system
        ThemeSettings.apply(theme: settingsTheme)
        ThemeSettings.applyStyles()
    }
}
