//
//  DictionaryInteractor.swift
//  ParticlesKit
//
//  Created by Qiang Huang on 7/11/20.
//  Copyright © 2020 dYdX. All rights reserved.
//

import Foundation

@objc open class DictionaryInteractor: BaseInteractor {
    @objc public dynamic var dictionary: [String: Any] = [:]

    public func set(_ value: Any?, for key: String) {
        let _key = "dictionary"
        let oldValue = dictionary[key]
        if let value = value {
            if let oldValue = oldValue {
                if let object = value as? NSObject, let oldObject = oldValue as? NSObject {
                    if object !== oldObject {
                        willChangeValue(forKey: _key)
                        dictionary[key] = value
                        didChangeValue(forKey: _key)
                    }
                } else {
                    willChangeValue(forKey: _key)
                    dictionary[key] = value
                    didChangeValue(forKey: _key)
                }
            } else {
                willChangeValue(forKey: _key)
                dictionary[key] = value
                didChangeValue(forKey: _key)
            }
        } else {
            if let _ = oldValue {
                willChangeValue(forKey: _key)
                dictionary[key] = value
                didChangeValue(forKey: _key)
            }
        }
    }
}
