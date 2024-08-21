//
//  Int+Utils.swift
//  Utilities
//
//  Created by Qiang Huang on 2/2/19.
//  Copyright © 2019 dYdX. All rights reserved.
//

import Foundation

extension Int {
    public static func ascending(int1: Int?, int2: Int?) -> Bool {
        if int1 != nil {
            if int2 != nil {
                return int1! < int2!
            } else {
                return false
            }
        } else {
            return true
        }
    }
}
