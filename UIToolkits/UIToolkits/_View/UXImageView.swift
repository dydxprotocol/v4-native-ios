//
//  UXImageView.swift
//  UIToolkits
//
//  Created by Qiang Huang on 9/16/21.
//  Copyright © 2021 dYdX. All rights reserved.
//

import UIKit
import Utilities

open class UXImageView: UIImageView {
    private var changed: Bool = false
    
    open override var image: UIImage? {
        didSet {
            changed = true
        }
    }

    open override func awakeFromNib() {
        let changed = changed
        super.awakeFromNib()
        if !changed {
            image = nil
        }
    }
}
