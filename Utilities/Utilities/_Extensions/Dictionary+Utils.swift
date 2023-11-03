//
//  Dictionary+Untils.swift
//  Utilities
//
//  Created by Qiang Huang on 10/28/18.
//  Copyright © 2019 dYdX. All rights reserved.
//

import Foundation

public class DictionaryUtils {
    public static func merge(_ dictionary1: [String: Any]?, with dictionary2: [String: Any]?) -> [String: Any]? {
        if let dictionary1 = dictionary1 {
            if let dictionary2 = dictionary2 {
                return dictionary1.merging(dictionary2, uniquingKeysWith: { _, last in last })
            } else {
                return dictionary1
            }
        } else {
            return dictionary2
        }
    }
}

extension Dictionary {
    public func percentEscaped() -> String {
        return map { key, value in
            let escapedKey = "\(key)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            let escapedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            return escapedKey + "=" + escapedValue
        }
        .joined(separator: "&")
    }
}

extension Dictionary where Key == String {
    public subscript(caseInsensitive key: Key) -> Value? {
        get {
            if let k = keys.first(where: { $0.caseInsensitiveCompare(key) == .orderedSame }) {
                return self[k]
            }
            return nil
        }
        set {
            if let k = keys.first(where: { $0.caseInsensitiveCompare(key) == .orderedSame }) {
                self[k] = newValue
            } else {
                self[key] = newValue
            }
        }
    }
}

extension CharacterSet {
    static let urlQueryValueAllowed: CharacterSet = {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="

        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        return allowed
    }()
}

extension Dictionary {
    public func filterNils<T: Any>() -> [Key: Value] where Value == Optional<T> {
        filter { $0.value != nil } as? [Key: T] ?? self
    }
}

