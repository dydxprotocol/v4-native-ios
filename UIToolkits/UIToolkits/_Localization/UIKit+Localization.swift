//
//  File.swift
//  UIToolkits
//
//  Created by Qiang Huang on 4/30/19.
//  Copyright © 2019 dYdX. All rights reserved.
//

import UIKit
import Utilities

extension UILabel {
}

extension UITextField {
    open override func awakeFromNib() {
        super.awakeFromNib()
        text = text?.localized
        placeholder = placeholder?.localized
    }
}

extension UITextView {
    open override func awakeFromNib() {
        super.awakeFromNib()
        text = text?.localized
    }
}

extension UINavigationItem {
    open override func awakeFromNib() {
        super.awakeFromNib()
        title = title?.localized
    }
}

extension UIBarItem {
    open override func awakeFromNib() {
        super.awakeFromNib()
        title = title?.localized
    }
}

extension UISegmentedControl {
    open override func awakeFromNib() {
        super.awakeFromNib()
        for i in 0 ..< numberOfSegments {
            let title = titleForSegment(at: i)
            setTitle(title?.localized, forSegmentAt: i)
        }
    }
}

extension UIButton {
    open override func awakeFromNib() {
        super.awakeFromNib()
        buttonTitle = buttonTitle?.localized
    }
}
