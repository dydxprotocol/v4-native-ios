//
//  OnOffSwitch.swift
//  UIToolkits
//
//  Created by Qiang Huang on 11/13/21.
//  Copyright © 2021 dYdX Trading Inc. All rights reserved.
//

import UIKit

@objc public class OnOffSwitch: UISwitch {
    @IBInspectable var onColor: UIColor?
    @IBInspectable var offColor: UIColor?

    @IBInspectable var onThumbColor: UIColor?
    @IBInspectable var offThumbColor: UIColor?

    override public var isOn: Bool {
        didSet {
            updateThumbColor(animated: true)
        }
    }

    override public func awakeFromNib() {
        super.awakeFromNib()

        /* For on state */
        if let onColor = onColor {
            onTintColor = onColor
        }

        /* For off state */
        if let offColor = offColor {
            tintColor = offColor
            layer.cornerRadius = frame.height / 2.0
            layer.backgroundColor = offColor.cgColor
            layer.opacity = 1.0
            backgroundColor = offColor
            alpha = 1.0
            clipsToBounds = true
        }
        updateThumbColor(animated: false)
    }

    private func updateThumbColor(animated: Bool) {
        if let onThumbColor = onThumbColor, let offThumbColor = offThumbColor {
            UIView.animate(self, type: animated ? .fade : .none, direction: .none, duration: UIView.defaultAnimationDuration) { [weak self] in
                self?.thumbTintColor = (self?.isOn == true) ? onThumbColor : offThumbColor
            } completion: { _ in
            }
        }
    }
}
