//
//  UIImageView+Tint.swift
//  UIToolkits
//
//  Created by Qiang Huang on 1/19/20.
//  Copyright © 2020 dYdX. All rights reserved.
//

import UIKit

extension UIImageView {
    open override func awakeFromNib() {
        super.awakeFromNib()
        tintColorDidChange()
    }
}
