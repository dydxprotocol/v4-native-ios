//
//  LocalFeatureFlagsCacheInteractor.swift
//  TrackingKit
//
//  Created by Qiang Huang on 11/21/18.
//  Copyright © 2018 dYdX. All rights reserved.
//

import Utilities

@objc public final class LocalFeatureFlagsCacheInteractor: LocalEntityCacheInteractor, SingletonProtocol, FeatureFlagsProtocol {
    public func value<T>(feature: String, defaultValue: T) -> T {
        defaultValue
    }
    
    public static var shared: LocalFeatureFlagsCacheInteractor = {
        LocalFeatureFlagsCacheInteractor(key: "features", default: "features_default.json")
    }()

    public static func mock() -> LocalFeatureFlagsCacheInteractor {
        let featurFlags = shared
        featurFlags.key = "mock"
        return featurFlags
    }

    override public func awakeAfter(using aDecoder: NSCoder) -> Any? {
        return LocalFeatureFlagsCacheInteractor.shared
    }

    public var featureFlags: [String: Any]? {
        get {
            return (entity as? DictionaryEntity)?.force.data
        }
        set {
            (entity as? DictionaryEntity)?.data = newValue
        }
    }

    public func refresh(completion: @escaping () -> Void) {
        completion()
    }

    public func activate(completion: @escaping () -> Void) {
        completion()
    }

    public func isOn(feature: String) -> Bool? {
        featureFlags?[feature] as? Bool
    }

    public func value(feature: String) -> String? {
        if let value = featureFlags?[feature] as? String {
            return value
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
