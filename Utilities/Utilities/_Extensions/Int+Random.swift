//
//  Int+Random.swift
//  Utilities
//
//  Created by Qiang Huang on 12/31/18.
//  Copyright © 2018 dYdX. All rights reserved.
//

import Foundation

public extension Int {
    static func random(lower: Int, upper: Int) -> Int {
        let range = upper - lower + 1
        return lower + Int(arc4random_uniform(UInt32(range)))
    }
}
