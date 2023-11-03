//
//  UIBarButtonItem+Target.swift
//  UIToolkits
//
//  Created by Qiang Huang on 11/15/18.
//  Copyright © 2018 dYdX. All rights reserved.
//

import UIKit

public extension UIBarButtonItem {
    func set(target: AnyObject?, action: Selector?) {
        self.target = target
        self.action = action
    }
}
