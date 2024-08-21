//
//  LocalFeatureFlagsCacheInteractor.swift
//  TrackingKit
//
//  Created by Qiang Huang on 11/21/18.
//  Copyright © 2018 dYdX. All rights reserved.
//

import Utilities

@objc public final class LocalDebugCacheInteractor: LocalEntityCacheInteractor, SingletonProtocol, DebugProtocol {
    public static var shared: LocalDebugCacheInteractor = {
        LocalDebugCacheInteractor(key: "debug", default: "debug_default.json")
    }()

    public static func mock() -> LocalDebugCacheInteractor {
        let debug = shared
        debug.key = "mock"
        debug.debug = ["api_replay": "p", "integration_test": "t"]
        return debug
    }

    public override func awakeAfter(using aDecoder: NSCoder) -> Any? {
        return LocalDebugCacheInteractor.shared
    }

    public var debug: [String: Any]? {
        get {
            return (entity as? DictionaryEntity)?.force.data
        }
        set {
            (entity as? DictionaryEntity)?.data = newValue
        }
    }
}
