//
//  UINavigationBar+Transparent.swift
//  UIToolkits
//
//  Created by Qiang Huang on 8/19/19.
//  Copyright © 2019 dYdX. All rights reserved.
//

import UIKit

public extension UINavigationBar {
    @IBInspectable var transparent: Bool {
        get {
            return backgroundImage(for: .default) == nil
        }
        set {
            if newValue == true {
                shadowImage = UIImage()
                isTranslucent = true
                setBackgroundImage(UIImage(), for: .default)
            } else {
                shadowImage = UIImage()
                isTranslucent = false
                setBackgroundImage(nil, for: .default)
            }
        }
    }
}
