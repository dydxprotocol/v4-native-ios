//
//  NSNumber+Rounding.swift
//  Utilities
//
//  Created by Qiang Huang on 5/28/21.
//  Copyright © 2021 dYdX. All rights reserved.
//

import Foundation

public extension NSDecimalNumber {
    func up(dp: Int16) -> NSDecimalNumber {
        return round(rm: .up, dp: dp)
    }

    func down(dp: Int16) -> NSDecimalNumber {
        return round(rm: .down, dp: dp)
    }

    func round(rm: NSDecimalNumber.RoundingMode, dp: Int16) -> NSDecimalNumber {
        return rounding(accordingToBehavior: NSDecimalNumberHandler(roundingMode: rm, scale: dp, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: false))
    }

    func round(rm: NSDecimalNumber.RoundingMode, stepSize: Double) -> NSDecimalNumber {
        let scale = scale(step: stepSize)
        return round(rm: rm, dp: scale)
    }

    func scale(step: Double) -> Int16 {
        if step == 1000 {
            return -3
        } else if step == 100 {
            return -2
        } else if step == 10 {
            return -1
        } else if step == 1.0 {
            return 0
        } else if step == 0.1 {
            return 1
        } else if step == 0.01 {
            return 2
        } else if step == 0.001 {
            return 3
        } else if step == 0.0001 {
            return 4
        } else if step == 0.00001 {
            return 5
        } else if step == 0.000001 {
            return 6
        } else if step == 0.0000001 {
            return 7
        } else if step == 0.00000001 {
            return 8
        } else {
            return 0
        }
    }
}
