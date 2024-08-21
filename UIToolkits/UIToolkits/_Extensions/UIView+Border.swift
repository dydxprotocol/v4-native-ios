//
//  UIView+Border.swift
//  UIToolkits
//
//  Created by Qiang Huang on 10/8/18.
//  Copyright © 2018 dYdX. All rights reserved.
//

import UIKit

@IBDesignable
public extension UIView {
    @IBInspectable var corner: CGFloat {
        get { return layer.cornerRadius }
        set { layer.cornerRadius = newValue }
    }

    @IBInspectable var borderWidth: CGFloat {
        get { return layer.borderWidth }
        set { layer.borderWidth = newValue }
    }

    @IBInspectable var borderColor: UIColor? {
        get {
            if let cgColor = self.layer.borderColor {
                return UIColor(cgColor: cgColor)
            } else {
                return UIColor.clear
            }
        }
        set { layer.borderColor = newValue?.cgColor }
    }

    @IBInspectable var shadowOpacity: Float {
        get { return layer.shadowOpacity }
        set {
            layer.shadowOpacity = newValue
            layer.masksToBounds = false
        }
    }

    @IBInspectable var shadowOffset: CGSize {
        get { return layer.shadowOffset }
        set { layer.shadowOffset = newValue }
    }

    @IBInspectable var shadowRadius: CGFloat {
        get { return layer.shadowRadius }
        set { layer.shadowRadius = newValue }
    }

    @IBInspectable var shadowColor: UIColor? {
        get {
            if let cgColor = self.layer.shadowColor {
                return UIColor(cgColor: cgColor)
            } else {
                return UIColor.clear
            }
        }
        set {
            if let color = newValue {
                layer.shadowColor = color.cgColor
            }
        }
    }
}
