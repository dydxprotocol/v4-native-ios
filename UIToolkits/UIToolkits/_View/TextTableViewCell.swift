//
//  TextTableViewCell.swift
//  UIToolkits
//
//  Created by Qiang Huang on 11/28/20.
//  Copyright © 2020 dYdX. All rights reserved.
//

import UIKit

open class TextTableViewCell: UITableViewCell {
    @IBOutlet var view: UIView? {
        didSet {
            updateTextColor()
        }
    }

    @IBOutlet var titleLabel: LabelProtocol? {
        didSet {
            updateTextColor()
        }
    }

    @IBOutlet var checkmark: UIImageView?

    override open var isSelected: Bool {
        didSet {
            updateSelected()
        }
    }

    public var title: String? {
        get { return titleLabel?.text }
        set { titleLabel?.text = newValue }
    }

    open func updateTextColor() {
        titleLabel?.textColor = view?.borderColor
    }

    open func updateSelected() {
        if let checkmark = checkmark {
            checkmark.visible = isSelected
        } else {
            if isSelected {
                titleLabel?.textColor = view?.backgroundColor
                view?.backgroundColor = view?.borderColor
            } else {
                view?.backgroundColor = titleLabel?.textColor
                titleLabel?.textColor = view?.borderColor
            }
        }
    }
}
