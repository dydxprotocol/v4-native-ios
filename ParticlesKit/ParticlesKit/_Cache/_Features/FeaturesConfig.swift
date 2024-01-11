//
//  FeaturesConfig.swift
//  ParticlesKit
//
//  Created by Qiang Huang on 10/20/21.
//  Copyright © 2021 dYdX Trading Inc. All rights reserved.
//

import Utilities

open class FeaturesConfig: NSObject, IOProtocol {
    @objc public dynamic var isLoading: Bool = false

    public var priority: Int = 0

    public func load(path: String, params: [String: Any]?, completion: @escaping IOReadCompletionHandler) {
        isLoading = true
        let path = path.lastPathComponent
        let data = FeatureService.shared?.flag(feature: path)
        isLoading = false
        completion(data, nil, priority, nil)
    }

    public func save(path: String, params: [String: Any]?, data: Any?, completion: IOWriteCompletionHandler?) {
    }

    public func modify(path: String, params: [String: Any]?, data: Any?, completion: IOWriteCompletionHandler?) {
    }

    public func delete(path: String, params: [String: Any]?, completion: IODeleteCompletionHandler?) {
    }
}
