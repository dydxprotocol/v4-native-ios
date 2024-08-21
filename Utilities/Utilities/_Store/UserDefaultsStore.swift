//
//  UserDefaultsStore.swift
//  Utilities
//
//  Created by Rui Huang on 3/21/23.
//  Copyright © 2023 dYdX Trading Inc. All rights reserved.
//

import Foundation

open class UserDefaultsStore: KeyValueStoreProtocol {
    public var dictionary: [String : Any]? {
        didSet {
            var keys = Set<String>()
            dictionary?.keys.forEach { key in
                userDefaults.setValue(dictionary?[key], forKey: key)
                keys.insert(key)
            }
            oldValue?.keys.forEach { key in
                if keys.contains(key) == false {
                    userDefaults.removeObject(forKey: key)
                }
            }
        }
    }
    
    private let userDefaults: UserDefaults
    
    public init(tag: String) {
        userDefaults = UserDefaults(suiteName: tag) ?? UserDefaults.standard
        dictionary = userDefaults.dictionaryRepresentation()
    }
    
    public func value(forKey key: String) -> Any? {
        userDefaults.value(forKey: key)
    }
    
    public func setValue(_ value: Any?, forKey key: String) {
        if let value = value {
            userDefaults.set(value, forKey: key)
            dictionary?[key] = value
        } else {
            userDefaults.removeObject(forKey: key)
            dictionary?.removeValue(forKey: key)
        }
    }
    
    public func reset() {
        let dictionary = userDefaults.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            userDefaults.removeObject(forKey: key)
            self.dictionary?.removeValue(forKey: key)
        }
    }
}
