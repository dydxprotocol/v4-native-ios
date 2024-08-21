//
//  ColorPalette.swift
//  UIToolkits
//
//  Created by Qiang Huang on 8/29/20.
//  Copyright © 2020 dYdX. All rights reserved.
//

import UIKit
import Utilities

public final class ColorPalette: NSObject, SingletonProtocol {
    public static var shared: ColorPalette = {
        ColorPalette()
    }()

    public static var parserOverwrite: Parser?

    override public var parser: Parser {
        return ColorPalette.parserOverwrite ?? super.parser
    }

    private var colors: [String: Any]?

    private var cache: [String: UIColor] = [:]

    public func color(text: String?) -> UIColor? {
        if let text = text {
            if let color = UIColor(hex: text) {
                return color
            } else {
                return color(keyed: text)
            }
        } else {
            return nil
        }
    }

    public func color(keyed colorText: String?) -> UIColor? {
        if let colorText = colorText {
            if let color = cache[colorText] {
                return color
            } else {
                if let hex = hex(keyed: colorText) {
                    let color = UIColor(hex: hex)
                    cache[colorText] = color
                    return color
                } else {
                    if let color = UIColor(hex: colorText) {
                        cache[colorText] = color
                        return color
                    } else {
                        assertionFailure("invalid color hex: \(colorText)")
                        let color = UIColor.red
                        cache[colorText] = color
                        return color
                    }
                }
            }
        }
        #if DEBUG
            return UIColor.red
        #else
            return nil
        #endif
    }

    public func color(system colorText: String?) -> UIColor? {
        switch colorText {
        case "label":
            if #available(iOS 13.0, *) {
                return UIColor.label
            } else {
                return color(keyed: "black")
            }

        case "secondary":
            if #available(iOS 13.0, *) {
                return UIColor.secondaryLabel
            } else {
                return color(keyed: "gray")
            }

        case "dark":
            if #available(iOS 13.0, *) {
                return UIColor.systemGray2
            } else {
                return color(keyed: "darkGray")
            }

        case "gray":
            if #available(iOS 13.0, *) {
                return UIColor.systemGray4
            } else {
                return color(keyed: "gray")
            }

        case "superlight":
            if #available(iOS 13.0, *) {
                return UIColor.systemGray6
            } else {
                return color(keyed: "gray0")
            }

        case "light":
            if #available(iOS 13.0, *) {
                return UIColor.systemGray4
            } else {
                return color(keyed: "gray2")
            }

        case "quaternary":
            if #available(iOS 13.0, *) {
                return UIColor.quaternaryLabel
            } else {
                return color(keyed: "lightGray")
            }

        case "disabled":
            if #available(iOS 13.0, *) {
                return UIColor.lightGray
            } else {
                return color(keyed: "lightGray")
            }

        case "background":
            if #available(iOS 13.0, *) {
                return UIColor.systemBackground
            } else {
                return color(keyed: "white")
            }

        case "clear":
            return UIColor.clear

        default:
            return color(keyed: colorText)
        }
    }

    public func hex(keyed color: String) -> String? {
        return parser.asString(colors?[color])
    }

    override public init() {
        super.init()

        colors = JsonLoader.load(bundles: Bundle.particles, fileName: "colors.json") as? [String: Any]
    }
}
