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
    
    open var userInfo: [String: String?]?

    public var excluded: Bool = false

    private var entity: DictionaryEntity?

    override public init() {
        super.init()

        if let destinations = (JsonLoader.load(bundle: Bundle.main, fileName: "events.json") ?? JsonLoader.load(bundles: Bundle.particles, fileName: "events.json")) as? [String: Any] {
            entity = DictionaryEntity()
            entity?.parse(dictionary: destinations)
        }
    }

    open func view(_ path: String?, action: String?, data: [String: Any]?, from: String?, time: Date?, revenue: NSNumber?, contextViewController: UIViewController?) {
        if !excluded {
            if let path = transform(path: path)?.trim() {
                if let action = action {
                    log(event: "\(path)_\(action)", data: data, revenue: revenue)
                } else {
                    log(event: path, data: data, revenue: revenue)
                }
            }
        }
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
