//
//  UXLabel.swift
//  UIToolkits
//
//  Created by Qiang Huang on 1/19/20.
//  Copyright © 2020 dYdX. All rights reserved.
//

import UIKit
import Utilities

open class UXLabel: UILabel {
    @IBInspectable public var italic: Bool = false
    @IBInspectable public var placeOlder: String?
    
    private var changed: Bool = false
    
    open override var text: String? {
        didSet {
            changed = true
        }
    }

    open override func awakeFromNib() {
        let changed = changed
        super.awakeFromNib()
        if italic {
            if let font = self.font {
                self.font = font.italic()
            }
        }
        if !changed {
            text = placeOlder
        }
    }
}
