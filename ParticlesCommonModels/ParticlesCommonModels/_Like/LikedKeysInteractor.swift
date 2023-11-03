//
//  LikedKeysInteractor.swift
//  InteractorLib
//
//  Created by Qiang Huang on 10/23/18.
//  Copyright © 2018 dYdX. All rights reserved.
//

import ParticlesKit
import Utilities

@objc open class LikedKeysInteractor: LocalEntityCacheInteractor, LikedObjectsProtocol {
    private let likedTag = "liked"
    private let dislikedTag = "unliked"

    public var liked: [String]? {
        get { return (entity as? DictionaryEntity)?.force.json?[likedTag] as? [String] }
        set {
            HapticFeedback.shared?.impact(level: .low)
            willChangeValue(forKey: #keyPath(liked))
            (entity as? DictionaryEntity)?.force.data?[likedTag] = newValue
            didChangeValue(forKey: #keyPath(liked))
        }
    }

    public var disliked: [String]? {
        get { return (entity as? DictionaryEntity)?.force.json?[dislikedTag] as? [String] }
        set {
            willChangeValue(forKey: #keyPath(disliked))
            (entity as? DictionaryEntity)?.force.data?[dislikedTag] = newValue
            didChangeValue(forKey: #keyPath(disliked))
        }
    }

    override open func createLoader() -> LoaderProtocol? {
        if let path = path {
            return LoaderProvider.shared?.localAsyncLoader(path: path, cache: self)
        }
        return nil
    }

    override open func entityObject() -> ModelObjectProtocol {
        let entity = DictionaryEntity().force
        entity.json?[likedTag] = [String]()
        entity.json?[dislikedTag] = [String]()
        return entity
    }
}
