//
//  FeatureFlagsStore.swift
//  Utilities
//
//  Created by Rui Huang on 3/31/23.
//  Copyright © 2023 dYdX Trading Inc. All rights reserved.
//

import Foundation

public class FeatureFlagsStore: UserDefaultsStore, FeatureFlagsProtocol {
    public static var shared: FeatureFlagsStore?

    public var featureFlags: [String: Any]? {
        get {
            dictionary
        }
        set {
            dictionary = newValue
        }
    }

    public func refresh(completion: @escaping () -> Void) {
        completion()
    }

    public func activate(completion: @escaping () -> Void) {
        completion()
    }

    public func isOn(feature: String) -> Bool? {
        if let value = featureFlags?[feature] as? Bool {
            return value
        }
        return nil
    }

    public func value(feature: String) -> String? {
        if let value = featureFlags?[feature] as? String {
            return value
        }
        return nil
    }
    
    public func value<T>(feature: String, defaultValue: T) -> T {
        let value = value(feature: feature)
        if let value = value as? T {
            return value
        }
        return defaultValue
    }

    public func customized() -> Bool {
        #if DEBUG
            return false
        #else
            return (featureFlags?.count ?? 0) > 0
        #endif
    }
}
