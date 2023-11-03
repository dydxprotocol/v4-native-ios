//
//  Collection+Random.swift
//  Utilities
//
//  Created by Qiang Huang on 12/31/18.
//  Copyright © 2018 dYdX. All rights reserved.
//

import Foundation

extension Collection {
    func random() -> Self.Iterator.Element? {
        let count = distance(from: startIndex, to: endIndex)
        if count > 0 {
            let roll = Int.random(lower: 0, upper: count - 1)
            return self[index(startIndex, offsetBy: roll)]
        }
        return nil
    }
}
