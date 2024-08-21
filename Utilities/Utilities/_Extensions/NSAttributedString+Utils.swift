//
//  NSAttributedString+Utils.swift
//  Utilities
//
//  Created by Rui Huang on 7/6/22.
//  Copyright © 2022 dYdX Trading Inc. All rights reserved.
//

import Foundation

public extension NSAttributedString {
    func appending(string: NSAttributedString) -> NSAttributedString {
        let mutableStr = NSMutableAttributedString(attributedString: self)
        mutableStr.append(string)
        return mutableStr
    }
}
