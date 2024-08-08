//
//  TransformerTracker.swift
//  PlatformParticles
//
//  Created by Qiang Huang on 1/21/20.
//  Copyright © 2020 dYdX. All rights reserved.
//

import ParticlesKit
import Utilities

open class TransformerTracker: NSObject & TrackingProtocol {
    public var excluded: Bool = false

    private var entity: DictionaryEntity?

    override public init() {
        super.init()

        if let destinations = (JsonLoader.load(bundle: Bundle.main, fileName: "events.json") ?? JsonLoader.load(bundles: Bundle.particles, fileName: "events.json")) as? [String: Any] {
            entity = DictionaryEntity()
            entity?.parse(dictionary: destinations)
        }
    }

    
    open func setUserId(_ userId: String?) {
        assertionFailure("TransformerTracker does not support setUserId, should override")
    }
    
    open func setUserProperty(_ value: Any?, forName: String) {
        assertionFailure("TransformerTracker does not support setUserProperty, should override")
    }
    
    open func leave(_ path: String?) {
    }

    open func transform(path: String?) -> String? {
        if let pathElements = path?.components(separatedBy: "/").compactMap({ element in
            element.trim()
        }) {
            let path = pathElements.joined(separator: "_")
            return (entity?.data?[path] as? String) ?? path
        } else {
            return nil
        }
    }

    open func log(event: String, data: [String: Any]?, revenue: NSNumber?) {
    }
}
