//
//  JsonKeychainCaching.swift
//  ParticlesKit
//
//  Created by Qiang Huang on 4/21/21.
//  Copyright © 2021 dYdX. All rights reserved.
//

import SimpleKeychain
import Utilities

open class JsonKeychainCaching: NSObject, JsonCachingProtocol {
    @objc public dynamic var isLoading: Bool = false
    
    private static let keychain = A0SimpleKeychain()
    public var priority: Int = 0

    public init(priority: Int = 0) {
        super.init()
        self.priority = priority
    }

    open func read(path: String, completion: @escaping JsonReadCompletionHandler) {
        if let data = JsonKeychainCaching.keychain.data(forKey: path), let object = try? JSONSerialization.jsonObject(with: data, options: []) {
            completion(object, nil)
        } else {
            completion(nil, nil)
        }
    }

    open func write(path: String, data: Any?, completion: JsonWriteCompletionHandler?) {
        do {
            if let data = data {
                let json = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
                JsonKeychainCaching.keychain.setData(json, forKey: path)
            } else {
                JsonKeychainCaching.keychain.deleteEntry(forKey: path)
            }
        } catch {
        }
        completion?(nil)
    }
}
