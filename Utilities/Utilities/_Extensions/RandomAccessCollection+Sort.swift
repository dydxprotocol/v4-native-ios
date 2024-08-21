//
//  RandomAccessCollection+Sort.swift
//  Utilities
//
//  Created by Qiang Huang on 11/11/21.
//  Copyright © 2021 dYdX Trading Inc. All rights reserved.
//

import Foundation

public extension RandomAccessCollection { // the predicate version is not required to conform to Comparable
    func insertionIndex(for predicate: (Element) -> ComparisonResult) -> Index? {
        var slice: SubSequence = self[...]

        while !slice.isEmpty {
            let middle = slice.index(slice.startIndex, offsetBy: slice.count / 2)
            switch predicate(slice[middle]) {
            case .orderedAscending:
                slice = slice[index(after: middle)...]

            case .orderedDescending:
                slice = slice[..<middle]

            case .orderedSame:
                return nil
            }
        }
        return slice.startIndex
    }

    func binarySearch(for predicate: (Element) -> ComparisonResult) -> Index? {
        var slice: SubSequence = self[...]

        while !slice.isEmpty {
            let middle = slice.index(slice.startIndex, offsetBy: slice.count / 2)
            switch predicate(slice[middle]) {
            case .orderedAscending:
                slice = slice[index(after: middle)...]

            case .orderedDescending:
                slice = slice[..<middle]

            case .orderedSame:
                return middle
            }
        }
        return nil
    }
}
