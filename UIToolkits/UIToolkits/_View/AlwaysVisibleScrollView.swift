//
//  AlwaysVisibleImageView.swift
//  UIToolkits
//
//  Created by Qiang Huang on 12/7/21.
//  Copyright © 2021 dYdX Trading Inc. All rights reserved.
//

import UIKit
import Utilities

@objc public class AlwaysOpaqueImageView: UIImageView {
    override public var alpha: CGFloat {
        didSet {
            alpha = 1
        }
    }
}

extension UIView {
    fileprivate struct AlwaysVisibleKey {
        static var alwaysVisible = "UIScrollView.alwaysVisible"
    }

    @IBInspectable var alwaysVisible: Bool {
        get {
            let isAlwaysVisible: NSNumber? = associatedObject(base: self, key: &AlwaysVisibleKey.alwaysVisible)
            if isAlwaysVisible?.boolValue ?? false {
                return true
            } else {
                return false
            }
        }
        set {
            if alwaysVisible != newValue {
                let isAlwaysVisible: NSNumber = NSNumber(value: newValue)
                retainObject(base: self, key: &AlwaysVisibleKey.alwaysVisible, value: isAlwaysVisible)
            }
        }
    }

    override open func awakeFromNib() {
        super.awakeFromNib()
        if alwaysVisible {
            if self is UIScrollView {
                for view in subviews {
                    if view.className().contains("_UIScrollViewScrollIndicator") {
                        view.alwaysVisible = true
                    }
                }
            }
        }
    }

    public static func classInit() {
        if let originalMethod = class_getInstanceMethod(UIView.self, #selector(setter: UIView.alpha)), let swizzledMethod = class_getInstanceMethod(UIView.self, #selector(swizzled_setAlpha)) {
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
    }

    @objc func swizzled_setAlpha(alpha: CGFloat) {
        if let myClassName = classNames().first, myClassName.contains("_UIScrollViewScrollIndicator") {
            if alwaysVisible {
                swizzled_setAlpha(alpha: 1.0)
            } else {
                swizzled_setAlpha(alpha: alpha)
            }
        } else {
            swizzled_setAlpha(alpha: alpha)
        }
    }
}
