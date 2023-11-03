//
//  Loader.swift
//  ParticlesKit
//
//  Created by John Huang on 12/29/18.
//  Copyright © 2019 dYdX. All rights reserved.
//

import Utilities

open class Loader<EntityClass>: NSObject, LoaderProtocol where EntityClass: NSObject & ModelObjectProtocol & ParsingProtocol {
    @objc public dynamic var isLoading: Bool {
        let loadingIo = io.first { io in
            io.isLoading
        }
        return loadingIo !== nil
    }
    
    internal var path: String
    internal var io: [IOProtocol]
    internal var fields: [String]?
    internal var loadTime: Date?
    internal var lastPriority: Int?
    internal var readerDebounce: Debouncer = Debouncer()
    internal var writerDebounce: Debouncer = Debouncer()
    public weak var cache: LocalCacheProtocol?

    public init(path: String, io: [IOProtocol], fields: [String]? = nil, cache: LocalCacheProtocol? = nil) {
        self.path = path
        self.io = io
        self.fields = fields
        self.cache = cache
        super.init()
    }

    open func load(params: [String: Any]?, completion: LoaderCompletionHandler?) {
        if let handler = readerDebounce.debounce() {
            handler.run({ [weak self] in
                if let self = self {
                    self.lastPriority = nil
                    for i in 0 ..< self.io.count {
                        let ioLoader = self.io[i]
                        ioLoader.priority = i
                        ioLoader.load(path: self.path, params: params) { [weak self] (data: Any?, _: Any?, priority: Int, error: Error?) in
                            handler.run({ [weak self] in
                                if let self = self {
                                    let lastPriority = self.lastPriority ?? -1
                                    if priority > lastPriority {
                                        self.lastPriority = priority
                                        if error == nil {
                                            self.parse(io: ioLoader, data: data, error: error, completion: completion)
                                        } else {
                                            completion?(ioLoader, data, nil, error)
                                        }
                                    }
                                }
                            }, delay: nil)
                        }
                    }
                }
            }, delay: nil)
        }
    }

    open func parse(io: IOProtocol?, data: Any?, error: Error?, completion: LoaderCompletionHandler?) {
        if let entities = parseEntities(data: data) {
            completion?(io, entities, loadTime, error)
        } else if let entity = parseEntity(data: data) {
            completion?(io, entity, loadTime, error)
        } else {
            completion?(io, nil, loadTime, error)
        }
    }

    open func parseEntities(data: Any?) -> [ModelObjectProtocol]? {
        if let result = result(data: data) {
            if let array = result as? [Any] {
                var entities = [ModelObjectProtocol]()
                for entityData in array {
                    if let entity = entity(data: entityData) {
                        entities.append(entity)
                    }
                }
                return entities
            } else if let map = result as? [String: [String: Any]] {
                var entities = [ModelObjectProtocol]()
                for (key, entityData) in map {
                    let merged = self.merge(data: entityData, key: key)
                    if let entity = entity(data: merged) {
                        entities.append(entity)
                    }
                }
                return entities
            }
        }
        return nil
    }
    
    open func merge(data: [String: Any], key: String) -> [String: Any] {
        var modified = data
        modified["map_key"] = key
        return modified
    }
    
    open func list(data: Any?) -> [[String: Any]]? {
        return data as? [[String: Any]]
    }
    
    open func map(data: Any?) -> [String: [String: Any]]? {
        return data as? [String: [String: Any]]
    }

    open func result(data: Any?) -> Any? {
        return list(data: data) ?? map(data: data)
    }

    private func parseEntity(data: Any?) -> ModelObjectProtocol? {
        if let result = data as? [String: Any] {
            return entity(data: result)
        }
        return nil
    }

    open func entity(data: Any?) -> ModelObjectProtocol? {
        if let entityData = data as? [String: Any] {
            let obj = entity(from: entityData)
            (obj as? ParsingProtocol)?.parse?(dictionary: entityData)
            return obj
        }
        return nil
    }

    open func entity(from data: [String: Any]?) -> ModelObjectProtocol {
        if let entity = cache?.entity(from: data) {
            return entity
        }
        return createEntity()
    }

    open func createEntity() -> ModelObjectProtocol {
        return EntityClass()
    }

    open func save(object: Any?) {
        if lastPriority == io.count - 1 {
            if let entity = object as? JsonPersistable, let data = entity.json {
                save(data: data)
            } else if let entities = object as? [JsonPersistable] {
                var data = [[String: Any]]()
                for entity in entities {
                    if let entityData = entity.json {
                        data.append(entityData)
                    }
                }
                save(data: data)
            } else if let entities = object as? [String: JsonPersistable] {
                var data = [[String: Any]]()
                for (_, entity) in entities {
                    if let entityData = entity.json {
                        data.append(entityData)
                    }
                }
                save(data: data)
            }
        }
    }

    open func save(data: Any?) {
        if let handler = writerDebounce.debounce() {
            handler.run({ [weak self] in
                if let self = self {
                    for i in 0 ..< self.io.count {
                        let ioLoader = self.io[i]
                        if !(ioLoader is ApiProtocol) {
                            ioLoader.save(path: self.path, params: nil, data: data, completion: nil)
                        }
                    }
                }
            }, delay: nil)
        }
    }
}
