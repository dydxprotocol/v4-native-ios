//
//  dydxClientState.swift
//  dydxStateManager
//
//  Created by Rui Huang on 4/20/23.
//

import Foundation
import Utilities

struct dydxClientState {
    private static var service: String {
        if let uuid = UIDevice.current.identifierForVendor?.uuidString {
            return "clientState" + uuid
        } else {
            return "clientState"
        }
    }
    private static var account: String {
        "dYdX"
    }

    private static let userDefaults = UserDefaults(suiteName: "dydxClientState")

    enum StorageType: String {
        case userDefault
        case keyChain
    }

    static func load<T: Codable>(storeKey: String, storeType: StorageType = .userDefault) -> T? {
        switch storeType {
        case .userDefault:
            if let data = userDefaults?.data(forKey: storeKey) {
                return try? PropertyListDecoder().decode(T.self, from: data)
            }
        case .keyChain:
            return SecureStore.shared.read(service: service, account: account, type: T.self)
        }

        return nil
    }

    static func store<T: Codable>(state: T, storeKey: String, storeType: StorageType = .userDefault) {
        switch storeType {
        case .userDefault:
            let encoder = PropertyListEncoder()
            if let encoded = try? encoder.encode(state) {
                userDefaults?.set(encoded, forKey: storeKey)
            }
        case .keyChain:
            SecureStore.shared.save(state, service: service, account: account)
        }
    }

    static func reset(storeType: StorageType = .userDefault) {
        switch storeType {
        case .userDefault:
            let dictionary = userDefaults?.dictionaryRepresentation()
            dictionary?.keys.forEach { key in
                userDefaults?.removeObject(forKey: key)
            }
        case .keyChain:
            SecureStore.shared.delete(service: service, account: account)
        }
    }
}
