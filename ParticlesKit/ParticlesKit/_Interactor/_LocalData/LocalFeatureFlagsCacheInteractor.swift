//
//  LocalFeatureFlagsCacheInteractor.swift
//  TrackingKit
//
//  Created by Qiang Huang on 11/21/18.
//  Copyright © 2018 dYdX. All rights reserved.
//

import Utilities

@objc public final class LocalFeatureFlagsCacheInteractor: LocalEntityCacheInteractor, SingletonProtocol, FeatureFlagsProtocol {
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
