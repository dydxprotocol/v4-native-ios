//
//  LocalEntityCacheInteractor.swift
//  ParticlesKit
//
//  Created by Qiang Huang on 12/25/18.
//  Copyright © 2018 dYdX. All rights reserved.
//

import Utilities

@objc open class LocalEntityCacheInteractor: LocalJsonCacheInteractor, InteractorProtocol {
    @objc open dynamic var entity: ModelObjectProtocol? {
        didSet {
            didSetEntity(oldValue: oldValue)
        }
    }

    public var dictionaryEntity: DictionaryEntity? {
        return entity as? DictionaryEntity
    }

    open func didSetEntity(oldValue: ModelObjectProtocol?) {
        changeObservation(from: oldValue, to: entity, keyPath: #keyPath(DictionaryEntity.data)) { [weak self] _, _, _, _ in
            self?.save()
        }
    }

    override open func createLoader() -> LoaderProtocol? {
        if let path = path {
            return Loader<DictionaryEntity>(path: path, io: [JsonDocumentFileCaching()], cache: self)
        }
        return nil
    }

    override open func entity(from data: [String: Any]?) -> ModelObjectProtocol? {
        return entity ?? entityObject()
    }

    open func entityObject() -> ModelObjectProtocol {
        return DictionaryEntity()
    }

    override open func receive(io: IOProtocol?, object: Any?, loadTime: Date?, error: Error?) {
        if error == nil {
            process(object: object as? (ModelObjectProtocol))
        }
    }

    open func process(object: ModelObjectProtocol?) {
        if let object = object {
            entity = object
        } else {
            entity = entityObject()
        }
    }

    override open func save() {
        loader?.save(object: entity)
    }
}
