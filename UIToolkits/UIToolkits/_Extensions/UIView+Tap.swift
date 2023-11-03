//
//  UIView+Tap.swift
//  UIToolkits
//
//  Created by Qiang Huang on 12/9/21.
//  Copyright © 2021 dYdX Trading Inc. All rights reserved.
//

import UIKit
import Utilities

public extension UIView {
    private struct TapKeys {
        static var tapKey = "Tap"
        static var tapFocusKey = "TapFocus"
    }

    private var tap: UITapGestureRecognizer? {
        get {
            return associatedObject(base: self, key: &TapKeys.tapKey)
        }
        set {
            if tap !== newValue {
                if let oldValue = tap {
                    removeGestureRecognizer(oldValue)
                }
                retainObject(base: self, key: &TapKeys.tapKey, value: newValue)
                if let newValue = newValue {
                    addGestureRecognizer(newValue)
                }
            }
        }
    }

    var tapFocus: UITextField? {
        get {
            return associatedObject(base: self, key: &TapKeys.tapFocusKey)
        }
        set {
            if tapFocus !== newValue {
                retainObject(base: self, key: &TapKeys.tapFocusKey, value: newValue)
                if newValue !== nil {
                    if tap === nil {
                        tap = UITapGestureRecognizer { [weak self] _ in
                            self?.tapFocus?.becomeFirstResponder()
                        }
                    }
                } else {
                    tap = nil
                }
            }
        }
    }
}
