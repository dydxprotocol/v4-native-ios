//
//  NumericUtils.swift
//  Utilities
//
//  Created by John Huang on 11/3/23.
//  Copyright © 2023 dYdX Trading Inc. All rights reserved.
//

import Foundation

public enum NumericFilter {
    case notNegative
}

public extension Double {
    func filter(filter: NumericFilter?) -> Double? {
        if (filter == .notNegative) {
            if self >= 0.0 {
                return self
            } else {
                return nil
            }
        } else {
            return self
        }
    }
}

public extension NSNumber {
    func filter(filter: NumericFilter?) -> NSNumber? {
        if (filter == .notNegative) {
            if self.doubleValue >= 0.0 {
                return self
            } else {
                return nil
            }
        } else {
            return self
        }
    }
}
