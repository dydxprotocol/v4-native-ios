//
//  LocalFeatureFlagsCacheInteractor.swift
//  TrackingKit
//
//  Created by Qiang Huang on 11/21/18.
//  Copyright © 2019 dYdX. All rights reserved.
//

import Utilities

@objc public protocol MapAppProtocol: NSObjectProtocol {
    var mapUrl: String? { get set }
}

@objc public final class LocalMapCacheInteractor: LocalEntityCacheInteractor, SingletonProtocol, MapAppProtocol {
    public static var shared: LocalMapCacheInteractor = {
        LocalMapCacheInteractor(key: "map", default: nil)
    }()

    public override func awakeAfter(using aDecoder: NSCoder) -> Any? {
        return LocalMapCacheInteractor.shared
    }

    public var mapUrl: String? {
        get {
            return (entity as? DictionaryEntity)?.data?["map"] as? String
        }
        set {
            if mapUrl != newValue {
                (entity as? DictionaryEntity)?.force.data?["map"] = newValue
                save()
            }
        }
    }

    public var map: [String: Any]? {
        get {
            return (entity as? DictionaryEntity)?.force.data
        }
        set {
            (entity as? DictionaryEntity)?.data = newValue
        }
    }
}
