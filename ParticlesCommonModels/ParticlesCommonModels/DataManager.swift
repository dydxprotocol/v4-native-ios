//
//  ListManager.swift
//  InteractorLib
//
//  Created by Qiang Huang on 11/10/18.
//  Copyright © 2018 Qiang Huang. All rights reserved.
//

import KVOController
import Utilities

@objc open class JsonCache: NSObject, InteractorProtocol, LocalCacheProtocol {
    open var key: String?
    open var defaultJson: String?
    open var loader: LoaderProtocol?
    public var debouncer: Debouncer = Debouncer()
    @objc open dynamic var entity: (NSObject & ModelObjectProtocol)? {
        didSet {
            if entity !== oldValue {
                let keyPath = #keyPath(DictionaryEntity.data)
                kvoController.unobserve(oldValue, keyPath: keyPath)
                kvoController.observe(dictionaryEntity, keyPath: keyPath, options: [.initial]) { [weak self] _, _, _ in
                    self?.save()
                }
            }
        }
    }

    private var dictionaryEntity: DictionaryEntity? {
        return entity as? DictionaryEntity
    }

    public var persistTag: String? {
        if let key = key {
            return "\(String(describing: type(of: self))).persist.\(key)"
        }
        return nil
    }

    public var persistDataFile: String? {
        if let persistTag = persistTag {
            return Directory.document?.stringByAppendingPathComponent(path: "\(persistTag).data.json")
        }
        return nil
    }

    public override init() {
        super.init()
    }

    public init(key: String? = nil, default defaultJson: String? = nil) {
        self.key = key
        self.defaultJson = defaultJson
        super.init()
        load()
    }

    open func load() {
        readData()
        loader = createLoader()
    }

    open func save() {
        writeData()
    }

    open func createLoader() -> LoaderProtocol? {
        return nil
    }

    open func load(data: Any?) {
        entity = data as? (NSObject & ModelObjectProtocol)
    }

    open func readData() {
        if let persistDataFile = self.persistDataFile, let dictionary = JsonLoader.load(file: persistDataFile) as? [String: Any] {
            entity = entity(from: dictionary)
        } else {
            entity = entity(from: nil)
        }
    }

    open func writeData() {
        if let entity = self.entity, let persistDataFile = self.persistDataFile, let persist = (entity as? PersistableEntity)?.persist {
            JsonWriter.write(persist, to: persistDataFile)
        }
    }

    public func entity(from data: [String: Any]?) -> (NSObject & ModelObjectProtocol)? {
        let entity = self.entity ?? createEntity()
        if let data = data {
            (entity as? ParsingProtocol)?.parseDictionary?(data)
        } else {
            readDefault(into: entity)
        }
        return entity
    }

    open func createEntity() -> (NSObject & ModelObjectProtocol) {
        return DictionaryEntity()
    }

    public func readDefault(into entity: (NSObject & ModelObjectProtocol)) {
        if let data = JsonLoader.load(bundle: Bundle.ui(), fileName: defaultJson) as? [String: Any] {
            (entity as? ParsingProtocol)?.parseDictionary?(data)
        }
    }
}
