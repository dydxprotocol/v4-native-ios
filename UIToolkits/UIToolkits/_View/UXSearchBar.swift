//
//  UXSearchBar.swift
//  UIToolkits
//
//  Created by Qiang Huang on 10/19/18.
//  Copyright © 2018 dYdX. All rights reserved.
//

import UIKit

open class UXSearchBar: UISearchBar {
    open override var intrinsicContentSize: CGSize {
        return CGSize(width: bounds.size.width, height: 44)
    }
}
