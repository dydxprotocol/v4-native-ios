//
//  Decimal+Utils.swift
//  Utilities
//
//  Created by Qiang Huang on 5/28/21.
//  Copyright © 2021 dYdX. All rights reserved.
//

import Foundation

public extension Decimal {
    func mod(_ b: Decimal) -> Decimal {
        var d = self / b
        var f: Decimal = 0
        NSDecimalRound(&f, &d, 0, .down)
        return self - (b * f)
    }

    mutating func round(_ scale: Int, _ roundingMode: NSDecimalNumber.RoundingMode) {
        var localCopy = self
        NSDecimalRound(&self, &localCopy, scale, roundingMode)
    }

    func rounded(_ scale: Int, _ roundingMode: NSDecimalNumber.RoundingMode) -> Decimal {
        var result = Decimal()
        var localCopy = self
        NSDecimalRound(&result, &localCopy, scale, roundingMode)
        return result
    }
}
