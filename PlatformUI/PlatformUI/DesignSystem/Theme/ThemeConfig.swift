//
//  ThemeConfig.swift
//  PlatformUI
//
//  Created by Rui Huang on 8/8/22.
//

import Foundation
import UIKit
import Utilities
import SwiftUI

public final class ThemeSettings: ObservableObject, SingletonProtocol {
    public static let shared = ThemeSettings()

    @Published public var themeConfig: ThemeConfig = .sampleThemeConfig {
        didSet {
            if themeConfig != oldValue {
                ThemeColorCache.shared.clear()
                ThemeFontCache.shared.clear()
            }
        }
    }
    @Published public var styleConfig: StyleConfig = .sampleStyleConfig

    public static var respondsToSystemTheme = true
}

// MARK: - ThemeConfig

public struct ThemeConfig: Codable, Equatable {
    public let id: String
    public let themeColor: ThemeColor
    public let themeFont: ThemeFont
}

public extension ThemeConfig {
    static let sampleThemeConfig = load(configJson: "SampleTheme.json")!

    static func load(configJson: String, bundle: Bundle? = nil) -> ThemeConfig? {
        _load(configJson: configJson, bundle: bundle)
    }
}

// MARK: - StyleConfig

public struct StyleConfig: Codable {
    public let styles: [String: ThemeStyle]
}

public extension StyleConfig {
    static let sampleStyleConfig = load(configJson: "SampleStyle.json") ?? StyleConfig(styles: [:])

    static func load(configJson: String, bundle: Bundle? = nil) -> StyleConfig? {
        let styles: [String: ThemeStyle]? = _load(configJson: configJson, bundle: bundle)
        if let styles = styles {
            return StyleConfig(styles: styles)
        } else {
            return nil
        }
    }
}

public struct ThemeStyle: Codable {
    init(_fontSize: String? = nil, _fontType: String? = nil, _layerColor: String? = nil, _textColor: String? = nil) {
        self._fontSize = _fontSize
        self._fontType = _fontType
        self._layerColor = _layerColor
        self._textColor = _textColor
    }

    let _fontSize, _fontType, _layerColor, _textColor: String?
}

public extension ThemeStyle {
    static let defaultStyle: ThemeStyle = ThemeSettings.shared.styleConfig.styles["default-style"]!

    var fontSize: ThemeFont.FontSize? {
        guard let _fontSize = _fontSize else {
            return nil
        }

        return ThemeFont.FontSize(rawValue: _fontSize)
    }

    var fontType: ThemeFont.FontType? {
        guard let _fontType = _fontType else {
            return nil
        }

        return ThemeFont.FontType(rawValue: _fontType)
    }

    var layerColor: ThemeColor.SemanticColor? {
        guard let _layerColor = _layerColor else {
            return nil
        }

        return ThemeColor.SemanticColor(rawValue: _layerColor)
    }

    var textColor: ThemeColor.SemanticColor? {
        guard let _textColor = _textColor else {
            return nil
        }

        return ThemeColor.SemanticColor(rawValue: _textColor)
    }

    func merge(from newStyle: Self) -> Self {
        let _fontSize = newStyle._fontSize ?? _fontSize
        let _fontType = newStyle._fontType ?? _fontType
        let _layerColor = newStyle._layerColor ?? _layerColor
        let _textColor = newStyle._textColor ?? _textColor
        return Self.init(_fontSize: _fontSize, _fontType: _fontType, _layerColor: _layerColor, _textColor: _textColor)
    }

    func themeColor(foreground: ThemeColor.SemanticColor) -> Self {
        let newStyle = ThemeStyle(_textColor: foreground.rawValue)
        return merge(from: newStyle)
    }

    func themeColor(background: ThemeColor.SemanticColor) -> Self {
        let newStyle = ThemeStyle(_layerColor: background.rawValue)
        return merge(from: newStyle)
    }

    func themeFont(fontType: ThemeFont.FontType? = nil, fontSize: ThemeFont.FontSize = .medium) -> Self {
        let fontType = fontType ?? .base
        let newStyle = ThemeStyle(_fontSize: fontSize.rawValue, _fontType: fontType.rawValue)
        return merge(from: newStyle)
    }
}

// MARK: - Color

public struct ThemeColor: Codable, Equatable {
    let color: [String: String]

    public enum SemanticColor: Hashable {
        case transparent

        case textPrimary
        case textSecondary
        case textTertiary

        case layer0
        case layer1
        case layer2
        case layer3
        case layer4
        case layer5
        case layer6
        case layer7

        case borderDefault
        case borderDestructive
        case borderButton

        case colorPurple
        case colorYellow
        case colorGreen
        case colorRed
        case colorWhite
        case colorBlack
        case colorFadedPurple
        case colorFadedGreen
        case colorFadedRed
        case colorFadedYellow

        case custom(rgb: String, alpha: Double?)

        init(rawValue: String) {
            switch rawValue {
            case "transparent": self = .transparent

            case "color_purple": self = .colorPurple
            case "color_yellow": self = .colorYellow
            case "color_green": self = .colorGreen
            case "color_red": self = .colorRed
            case "color_white": self = .colorWhite
            case "color_black": self = .colorBlack
            case "color_faded_purple": self = .colorFadedPurple
            case "color_faded_green": self = .colorFadedGreen
            case "color_faded_red": self = .colorFadedRed
            case "color_faded_yellow": self = .colorFadedYellow

            case "layer_0": self = .layer0
            case "layer_1": self = .layer1
            case "layer_2": self = .layer2
            case "layer_3": self = .layer3
            case "layer_4": self = .layer4
            case "layer_5": self = .layer5
            case "layer_6": self = .layer6
            case "layer_7": self = .layer7

            case "text_primary": self = .textPrimary
            case "text_secondary": self = .textSecondary
            case "text_tertiary": self = .textTertiary

            case "border_default": self = .borderDefault
            case "border_destructive": self = .borderDestructive
            case "border_button": self = .borderButton
            default:
                if let custom = parseCustomRawValue(rawValue: rawValue) {
                    self = .custom(rgb: custom.rgb, alpha: custom.alpha)
                } else {
                    assertionFailure("Unable to parse color \(rawValue)")
                    self = .transparent
                }
            }
        }

        public var rawValue: String {
            switch self {
            case .transparent: return "transparent"

            case .layer0: return "layer_0"
            case .layer1: return "layer_1"
            case .layer2: return "layer_2"
            case .layer3: return "layer_3"
            case .layer4: return "layer_4"
            case .layer5: return "layer_5"
            case .layer6: return "layer_6"
            case .layer7: return "layer_7"

            case .textPrimary: return "text_primary"
            case .textSecondary: return "text_secondary"
            case .textTertiary: return "text_tertiary"

            case .borderDefault: return "border_default"
            case .borderDestructive: return "border_destructive"
            case .borderButton: return "border_button"

            case .colorPurple: return "color_purple"
            case .colorYellow: return "color_yellow"
            case .colorGreen: return "color_green"
            case .colorRed: return "color_red"
            case .colorWhite: return "color_white"
            case .colorBlack: return "color_black"
            case .colorFadedPurple: return "color_faded_purple"
            case .colorFadedGreen: return "color_faded_green"
            case .colorFadedRed: return "color_faded_red"
            case .colorFadedYellow: return "color_faded_yellow"
            case .custom(rgb: let rgb, let alpha): return "\(rgb),\(String(describing: alpha))"
            }
        }
    }
}

public extension ThemeColor {
    private func uiColor(of semanticColor: SemanticColor) -> UIColor {
        switch semanticColor {
        case .transparent:
            return UIColor.clear
        case .custom(rgb: let rgb, alpha: let alpha):
            return UIColor(hex: rgb)?.withAlphaComponent(alpha ?? 1) ?? .clear
        default:
            assert(UIColor(hex: color[semanticColor.rawValue]) != nil, "color does not exist: \(semanticColor.rawValue)")
            return UIColor(hex: color[semanticColor.rawValue]) ?? .clear
        }
    }

    func color(of layerColor: SemanticColor) -> Color {
        if let color = ThemeColorCache.shared.get(layerColor) {
            return color
        }
        let uiColor = uiColor(of: layerColor)
        let color = Color(uiColor: uiColor)
        ThemeColorCache.shared.set(layerColor, color: color)
        return color
    }
}

// MARK: - Font

public struct ThemeFont: Codable, Equatable {
    let size: [String: String]
    let type: [String: FontTypeDetail]

    public enum FontSize: Hashable {
        case largest, larger, large, medium, small, smaller, smallest
        case custom(size: Float)

        init(rawValue: String) {
            switch rawValue {
            case "largest": self = .largest
            case "larger": self = .larger
            case "large": self = .large
            case "medium": self = .medium
            case "small": self = .small
            case "smaller": self = .smaller
            case "smallest": self = .smallest

            default:
                if let size = Float(rawValue), size > 0 {
                    self = .custom(size: size)
                } else {
                    assertionFailure("Unable to parse font size \(rawValue)")
                    self = .medium
                }
            }
        }

        var rawValue: String {
            switch self {
            case .largest: return "largest"
            case .larger: return "larger"
            case .large: return "large"
            case .medium: return "medium"
            case .small: return "small"
            case .smaller: return "smaller"
            case .smallest: return "smallest"
            case .custom(size: let size): return String(size)
            }
        }
    }

    public enum FontType: Hashable {
        case minus, base, plus, number
        case custom(name: String)

        init(rawValue: String) {
            switch rawValue {
            case "minus": self = .minus
            case "base": self = .base
            case "plus": self = .plus
            case "number": self = .number
            default: self = .custom(name: rawValue)
            }
        }

        var rawValue: String {
            switch self {
            case .minus: return "minus"
            case .base: return "base"
            case .plus: return "plus"
            case .number: return "number"
            case .custom(name: let name): return name
            }
        }

        var defaultWeight: UIFont.Weight {
            switch self {
            case .minus:
                return .regular
            case .base:
                return .medium
            case .plus:
                return .bold
            case .number:
                return .medium
            case .custom(let name):
                preconditionFailure("unrecognized font type \(name)")
                return .regular
            }
        }

        var defaultFontName: String {
            switch self {
            case .minus:
                return UIFont.systemFont(ofSize: 0).fontName
            case .base:
                return UIFont.systemFont(ofSize: 0).fontName
            case .plus:
                return UIFont.boldSystemFont(ofSize: 0).fontName
            case .number:
                return UIFont.monospacedSystemFont(ofSize: 0, weight: defaultWeight).fontName
            case .custom(let name):
                preconditionFailure("unrecognized font type \(name)")
                return UIFont.systemFont(ofSize: 0).fontName
            }
        }
    }
}

public struct FontTypeDetail: Codable, Equatable {
    let name: String?
}

public extension ThemeFont {

    func uiFont(of fontType: FontType, fontSize: FontSize) -> UIFont? {
        let sizeValue: Float
        switch fontSize {
        case .custom(size: let size):
            sizeValue = size
        default:
            if let sizeString = size[fontSize.rawValue], let size = Float(sizeString) {
                sizeValue = size
            } else {
            //    assertionFailure("fontSize not found \(size)")
                return nil
            }
        }

        if let fontName = type[fontType.rawValue]?.name, fontName.length > 0 {
            return loadFont(name: fontName,
                            size: sizeValue)
        }
        switch fontType {
        case .custom:
            return nil
        case .number:
            return UIFont.monospacedSystemFont(ofSize: CGFloat(sizeValue), weight: fontType.defaultWeight)
        case .plus:
            return UIFont.boldSystemFont(ofSize: CGFloat(sizeValue)).withWeight(fontType.defaultWeight)
        case .base:
            return UIFont.systemFont(ofSize: CGFloat(sizeValue)).withWeight(fontType.defaultWeight)
        case .minus:
            return UIFont.systemFont(ofSize: CGFloat(sizeValue)).withWeight(fontType.defaultWeight)
        }
    }

    private func loadFont(name: String, size: Float) -> UIFont? {
        let font = UIFont(name: name, size: CGFloat(size))
        guard let font = font else {
            //assertionFailure("Font not found: \(name) \(size)")
            return nil
        }
        return font
    }

    func font(of fontType: FontType, fontSize: FontSize) -> Font? {
        if let cached = ThemeFontCache.shared.get(fontType: fontType, fontSize: fontSize) {
            return cached
        }
        if let uiFont = uiFont(of: fontType, fontSize: fontSize) {
            let font = Font(uiFont as CTFont)
            ThemeFontCache.shared.set(fontType: fontType, fontSize: fontSize, font: font)
            return font
        }
        return nil
    }
}

public extension ThemeColor.SemanticColor {
    var uiColor: UIColor {
        ThemeSettings.shared.themeConfig.themeColor.uiColor(of: self)
    }
    var color: Color {
        ThemeSettings.shared.themeConfig.themeColor.color(of: self)
    }
}

// Private

private func _load<T: Decodable>(configJson: String, bundle: Bundle? = nil) -> T? {
    let bundle = bundle ?? Bundle(for: PlatformUIBundleClass.self)
    if let url = bundle.url(forResource: configJson, withExtension: "") {
        do {
            let data = try Data(contentsOf: url)
            let obj = try? JSONDecoder().decode(T.self, from: data)
            return obj
        } catch {
            print("error:\(error)")
        }
    }
    return nil
}

private func parseCustomRawValue(rawValue: String) -> (rgb: String, alpha: Double?)? {
    if rawValue.starts(with: "#") {
        let split = rawValue.split(separator: ",")
        var alpha: Double? = 1.0
        if split.count > 1 {
            let value = String(split[1])
            alpha = Parser().asNumber(value)?.doubleValue
        }
        if split.count > 0,
           UIColor(hex: String(split[0])) != nil {
            return (rgb: String(split[0]), alpha: alpha)
        }
    }
    return nil
}

extension UIFont {
    func withWeight(_ weight: UIFont.Weight) -> UIFont {
        var attributes = fontDescriptor.fontAttributes
        var traits = (attributes[.traits] as? [UIFontDescriptor.TraitKey: Any]) ?? [:]

        traits[.weight] = weight

        attributes[.name] = nil
        attributes[.traits] = traits
        attributes[.family] = familyName

        let descriptor = UIFontDescriptor(fontAttributes: attributes)

        return UIFont(descriptor: descriptor, size: pointSize)
    }
}
