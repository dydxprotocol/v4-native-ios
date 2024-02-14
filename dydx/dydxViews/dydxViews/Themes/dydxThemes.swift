//
//  dydxThemes.swift
//  dydxViews
//
//  Created by Rui Huang on 8/12/22.
//  Copyright © 2022 dYdX Trading Inc. All rights reserved.
//

import Foundation
import PlatformUI
import CoreText
import UIKit
import SwiftUI
import Utilities

public enum dydxThemeType: String {
    case dark
    case classicDark = "classic_dark"
    case light
    case system

    fileprivate var configFileName: String? {
        switch self {
        case .classicDark: return "ThemeClassicDark.json"
        case .dark: return "ThemeDark.json"
        case .light: return "ThemeLight.json"
        case .system: return nil
        }
    }

    fileprivate var config: ThemeConfig? {
        guard let configFileName = self.configFileName else { return nil }
        return ThemeConfig.load(configJson: configFileName, bundle: Bundle(for: dydxViewBundleClass.self))
    }
}

public var currentThemeType = dydxThemeType.dark

private var loadFontOnce: Void = {
    let fonts = Bundle(for: dydxViewBundleClass.self).urls(forResourcesWithExtension: "otf", subdirectory: nil)
    fonts?.forEach({ url in
        CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
    })
}()

public extension ThemeSettings {
    static let defaultTheme = dydxThemeType.dark

    static var shouldSwapColorDirectionPreference: Bool { SettingsStore.shared?.value(forKey: "direction_color_preference") as? String == "red_is_up" }
    static var positiveSideStyleKey: String { shouldSwapColorDirectionPreference ? "side-minus" : "side-plus" }
    static var negativeSideStyleKey: String { shouldSwapColorDirectionPreference ? "side-plus" : "side-minus" }
    static var positiveTextStyleKey: String { shouldSwapColorDirectionPreference ? "signed-minus" : "signed-plus" }
    static var negativeTextStyleKey: String { shouldSwapColorDirectionPreference ? "signed-plus" : "signed-minus" }
    static var positiveLayerStyleKey: String { shouldSwapColorDirectionPreference ? "signed-minus-layer" : "signed-plus-layer" }
    static var negativeLayerStyleKey: String { shouldSwapColorDirectionPreference ? "signed-plus-layer" : "signed-minus-layer" }

    static var positiveColor: ThemeColor.SemanticColor {
        shared.styleConfig.styles[positiveTextStyleKey]?.textColor ?? ThemeColor.SemanticColor.colorGreen
    }

    static var negativeColor: ThemeColor.SemanticColor {
        shared.styleConfig.styles[negativeTextStyleKey]?.textColor ?? ThemeColor.SemanticColor.colorRed
    }

    static var positiveColorLayer: ThemeColor.SemanticColor {
        shared.styleConfig.styles[positiveLayerStyleKey]?.layerColor ?? .colorGreen
    }

    static var negativeColorLayer: ThemeColor.SemanticColor {
        shared.styleConfig.styles[negativeLayerStyleKey]?.layerColor ?? .colorRed
    }

//    @available(*, deprecated, message: "use apply(theme: ThemeSettings.dydxThemeType) instead")
    static func applyLightTheme() {
        apply(theme: .light)
    }

//    @available(*, deprecated, message: "use apply(theme: ThemeSettings.dydxThemeType) instead")
    static func applyDarkTheme() {
        apply(theme: .dark)
    }

    static func apply(theme: dydxThemeType) {
        registerFonts()
        switch theme {
        case .classicDark, .dark, .light:
            if let config = theme.config {
                shared.themeConfig = config
                currentThemeType = theme
            } else {
                assertionFailure("\(theme.configFileName ?? "theme config file") not found")
            }
        case .system:
            if UITraitCollection.current.userInterfaceStyle == .dark {
                apply(theme: .dark)
            } else {
                apply(theme: .light)
            }
        }

        UITabBar.appearance().tintColor = ThemeColor.SemanticColor.textPrimary.uiColor
        UIApplication.shared.windows.first?.reload()
        ImageFactory.reload()
    }

    static func applyStyles() {
        if let config = StyleConfig.load(configJson: "dydxStyle.json", bundle: Bundle(for: dydxViewBundleClass.self)) {
            shared.styleConfig = config
        } else {
            assertionFailure("dydxStyle.json not found")
        }
    }

    static private func registerFonts() {
        _ = loadFontOnce
    }
}

public enum GradientType {
    case none, plus, minus
}

public extension View {
    func themeGradient(background: ThemeColor.SemanticColor, gradientType: GradientType) -> some View {
        modifier(GradientTypeModifier(layerColor: background, gradientType: gradientType))
    }
}

struct GradientTypeModifier: ViewModifier {
    @EnvironmentObject var themeSettings: ThemeSettings

    let layerColor: ThemeColor.SemanticColor
    let gradientType: GradientType

    func body(content: Content) -> some View {
        switch gradientType {
        case .none:
            content.themeColor(background: layerColor)
        case .plus:
            let uicolor = ThemeSettings.positiveColor.uiColor
            content.themeGradient(background: layerColor, gradientColor: Color(uicolor))
        case .minus:
            let uicolor = ThemeSettings.negativeColor.uiColor
            content.themeGradient(background: layerColor, gradientColor: Color(uicolor))
        }
    }
}

private extension UIWindow {

    /// Unload all views and add back.
    /// Useful for applying `UIAppearance` changes to existing views.
    func reload() {
        backgroundColor = ThemeColor.SemanticColor.layer0.uiColor
        subviews.forEach { view in
            view.removeFromSuperview()
            addSubview(view)
        }
    }
}

private extension Array where Element == UIWindow {

    /// Unload all views for each `UIWindow` and add back.
    /// Useful for applying `UIAppearance` changes to existing views.
    func reload() {
        forEach { $0.reload() }
    }
}
