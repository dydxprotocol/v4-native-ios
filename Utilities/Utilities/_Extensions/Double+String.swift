//
//  Double+String.swift
//  Utilities
//
//  Created by Qiang Huang on 11/28/20.
//  Copyright © 2020 dYdX. All rights reserved.
//

import Foundation

extension Double {
    public var shortString: String {
        if isNaN {
            return "NaN"
        }
        if isInfinite {
            return "\(self < 0.0 ? "-" : "+")Infinity"
        }
        let units = ["", "k", "M"]
        var interval = self
        var i = 0
        while i < units.count - 1 {
            if abs(interval) < 1000.0 {
                break
            }
            i += 1
            interval /= 1000.0
        }
        // + 2 to have one digit after the comma, + 1 to not have any.
        // Remove the * and the number of digits argument to display all the digits after the comma.
        return "\(String(format: "%0.*g", Int(log10(abs(interval))) + 2, interval))\(units[i])"
    }

    public func round(to places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }

    public func round(size: Double) -> Double {
        return round(to: places(size: size))
    }

    private func places(size: Double) -> Int {
        switch size {
        case 1000.0:
            return -3
        case 100.0:
            return -2
        case 10.0:
            return -1
        case 1.0:
            return 0
        case 0.1:
            return 1
        case 0.01:
            return 2
        case 0.001:
            return 3
        case 0.0001:
            return 4
        case 0.00001:
            return 5
        case 0.000001:
            return 6
        default:
            return 0
        }
    }
}
