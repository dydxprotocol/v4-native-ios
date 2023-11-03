//
//  UITabbar+Transparent.swift
//  UIToolkits
//
//  Created by Qiang Huang on 9/19/21.
//  Copyright © 2021 dYdX. All rights reserved.
//

import UIKit

public extension UITabBar {
    @IBInspectable var transparent: Bool {
        get {
            return backgroundImage != nil
        }
        set {
            if newValue == true {
                backgroundImage = UIImage()
                shadowImage = UIImage()
                isTranslucent = true
            } else {
                backgroundImage = nil
                shadowImage = nil
                isTranslucent = false
            }
        }
    }
}
