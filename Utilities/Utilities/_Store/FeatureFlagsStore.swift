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

    public func flag(feature: String?) -> Any? {
        if let feature = feature {
            if let value = featureFlags?[feature] {
                if (value as? String) == "<null>" {
                    return nil
                }
                return value
            }
        }
        return nil
    }

    public func customized() -> Bool {
        #if DEBUG
            return false
        #else
            return (featureFlags?.count ?? 0) > 0
        #endif
    }
}
