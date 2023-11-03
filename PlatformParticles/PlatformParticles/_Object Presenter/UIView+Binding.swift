//
//  UIView+Binding.swift
//  PlatformParticles
//
//  Created by Qiang Huang on 4/27/19.
//  Copyright © 2019 dYdX. All rights reserved.
//

import UIKit
import Utilities

extension UIView {
    private struct AssociatedKey {
        static var bindingKey = "view.text.binding"
    }

    @IBInspectable public var binding: String? {
        get {
            return associatedObject(base: self, key: &AssociatedKey.bindingKey)
        }
        set {
            retainObject(base: self, key: &AssociatedKey.bindingKey, value: newValue)
        }
    }
}
