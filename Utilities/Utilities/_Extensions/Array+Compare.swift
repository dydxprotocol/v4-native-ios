//
//  Array+Compare.swift
//  Utilities
//
//  Created by Qiang Huang on 1/19/20.
//  Copyright © 2020 dYdX. All rights reserved.
//

import Foundation

extension Array {
    public func object(at index: Int) -> Element? {
        if index < count {
            return self[index]
        }
        return nil
    }

    public func at(_ index: Int) -> Element? {
        if index < count {
            return self[index]
        }
        return nil
    }
}

extension Array where Element: NSObjectProtocol {
    public func containsSame(as other: [Element]?) -> Bool {
        if let other = other {
            if count == other.count {
                var pass = true
                for i in 0 ..< count {
                    if self[i] !== other[i] {
                        pass = false
                        break
                    }
                }
                return pass
            }
        }
        return false
    }

    public mutating func add(_ object: Element?) {
        if let object = object {
            append(object)
        }
    }

    public func maybe() -> [Element]? {
        if count > 0 {
            return self
        }
        return nil
    }
}

extension Array {
    public func filterNils<T>() -> [T] where Element == T? {
        compactMap { $0 }
    }
}
