//
//  TextCollectionViewCell.swift
//  UIToolkits
//
//  Created by Qiang Huang on 10/15/18.
//  Copyright © 2018 dYdX. All rights reserved.
//

import UIKit

open class TextCollectionViewCell: UICollectionViewCell {
    @IBInspectable var unselectedBackgroundColor: String?
    @IBInspectable var selectedBackgroundColor: String?
    @IBInspectable var unselectedTextColor: String?
    @IBInspectable var selectedTextColor: String?

    @IBOutlet var view: UIView? {
        didSet {
            updateTextColor()
            updateSelected()
        }
    }

    @IBOutlet var textLabel: LabelProtocol? {
        didSet {
            updateTextColor()
            updateSelected()
        }
    }

    override open var isSelected: Bool {
        didSet {
            if isSelected != oldValue {
                updateSelected()
            }
        }
    }

    public var text: String? {
        get { return textLabel?.text }
        set { textLabel?.text = newValue }
    }

    open func updateTextColor() {
        textLabel?.textColor = view?.borderColor
    }

    open func updateSelected() {
        if isSelected {
            if let selectedTextColor = selectedTextColor {
                textLabel?.textColor = ColorPalette.shared.color(system: selectedTextColor)
            } else {
                view?.backgroundColor = textLabel?.textColor
            }
            if let selectedBackgroundColor = selectedBackgroundColor {
                view?.backgroundColor = ColorPalette.shared.color(system: selectedBackgroundColor)
            } else {
                textLabel?.textColor = view?.borderColor
            }
        } else {
            if let unselectedTextColor = unselectedTextColor {
                textLabel?.textColor = ColorPalette.shared.color(system: unselectedTextColor)
            } else {
                textLabel?.textColor = view?.backgroundColor
            }
            if let unselectedBackgroundColor = unselectedBackgroundColor {
                view?.backgroundColor = ColorPalette.shared.color(system: unselectedBackgroundColor)
            } else {
                view?.backgroundColor = view?.borderColor
            }
        }
    }
}
