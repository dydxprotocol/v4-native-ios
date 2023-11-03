//
//  UIView+Color.swift
//  UIToolkits
//
//  Created by Qiang Huang on 8/29/20.
//  Copyright © 2020 dYdX. All rights reserved.
//

import UIKit
import Utilities

@objc public extension UIView {
    fileprivate struct ColorKey {
        static var background = "view.color.background"
        static var border = "view.color.border"
        static var text = "view.color.text"
    }

    @IBInspectable var backgroundColorName: String? {
        get {
            return associatedObject(base: self, key: &ColorKey.background)
        }
        set {
            retainObject(base: self, key: &ColorKey.background, value: newValue)
            setupBackgroundColor()
        }
    }

    @objc func setupBackgroundColor() {
        if let backgroundColorName = backgroundColorName, let color = ColorPalette.shared.color(system: backgroundColorName) {
            backgroundColor = color
        }
    }

    @IBInspectable var borderColorName: String? {
        get {
            return associatedObject(base: self, key: &ColorKey.border)
        }
        set {
            retainObject(base: self, key: &ColorKey.border, value: newValue)
            setupBorderColor()
        }
    }

    @objc func setupBorderColor() {
        if let borderColorName = borderColorName, let color = ColorPalette.shared.color(keyed: borderColorName) {
            borderColor = color
        }
    }
}

@objc public extension UIButton {
    @IBInspectable var textColorName: String? {
        get {
            return associatedObject(base: self, key: &ColorKey.text)
        }
        set {
            retainObject(base: self, key: &ColorKey.text, value: newValue)
            setupTextColor()
        }
    }

    @objc func setupTextColor() {
        if let textColorName = textColorName, let color = ColorPalette.shared.color(keyed: textColorName) {
            setTitleColor(color, for: .normal)
        }
    }
}

@objc public extension UILabel {
    @IBInspectable var textColorName: String? {
        get {
            return associatedObject(base: self, key: &ColorKey.text)
        }
        set {
            retainObject(base: self, key: &ColorKey.text, value: newValue)
            setupTextColor()
        }
    }

    @objc func setupTextColor() {
        if let textColorName = textColorName, let color = ColorPalette.shared.color(keyed: textColorName) {
            textColor = color
        }
    }
}
