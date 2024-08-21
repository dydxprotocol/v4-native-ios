//
//  OutlineLabel.swift
//  UIToolkits
//
//  Created by Qiang Huang on 8/29/20.
//  Copyright © 2020 dYdX. All rights reserved.
//

import UIKit
import Utilities

class OutlinedLabel: UILabel {
    @IBInspectable public var outlineWidth: CGFloat = 1
    @IBInspectable public var outlineColor: UIColor = UIColor.label

    override func drawText(in rect: CGRect) {
        let strokeTextAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.strokeColor: outlineColor,
            NSAttributedString.Key.strokeWidth: -1 * outlineWidth,
        ]

        attributedText = NSAttributedString(string: text ?? "", attributes: strokeTextAttributes)
        super.drawText(in: rect)
    }
}
