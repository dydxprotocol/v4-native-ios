//
//  UIResponder+First.swift
//  UIToolkits
//
//  Created by Qiang Huang on 9/1/19.
//  Copyright © 2019 dYdX. All rights reserved.
//

import UIKit

extension UIResponder {
    private weak static var _current: UIResponder?

    public static var current: UIResponder? {
        UIResponder._current = nil
        UIApplication.shared.sendAction(#selector(findFirstResponder(_:)), to: nil, from: nil, for: nil)
        return UIResponder._current
    }

    @objc internal func findFirstResponder(_ sender: AnyObject) {
        UIResponder._current = self
    }
}
