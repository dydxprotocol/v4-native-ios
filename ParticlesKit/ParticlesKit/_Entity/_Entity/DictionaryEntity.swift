//
//  DictionaryEntity.swift
//  EntityLib
//
//  Created by John Huang on 10/11/18.
//  Copyright © 2019 dYdX. All rights reserved.
//

import Utilities

open class DictionaryEntity: NSObject, ModelObjectProtocol, ParsingProtocol, JsonPersistable, DirtyProtocol {
    @objc open dynamic var data: [String: Any]?

    public var dirty_time: Date? {
        get {
            return parser.asDate(data?["dirty_time"])
        }
        set {
            let since1970 = parser.asInt(newValue)

            if dirty_time != parser.asDate(since1970) {
                let triggerDirty = (dirty_time == nil && newValue != nil) || (dirty_time != nil && newValue == nil)
                if triggerDirty {
                    willChangeValue(forKey: "dirty")
                }
                willChangeValue(forKey: "dirty_time")
                force.data?["dirty_time"] = since1970
                didChangeValue(forKey: "dirty_time")
                if triggerDirty {
                    didChangeValue(forKey: "dirty")
                }
            }
        }
    }

    public var dirty: Bool {
        get {
            return dirty_time != nil
        }
        set {
            if newValue {
                dirty_time = Date()
            } else {
                dirty_time = nil
            }
        }
    }

    public var force: DictionaryEntity {
        if data == nil {
            data = [:]
        }
        return self
    }

    open var json: [String: Any]? {
        get { return data }
        set {
            if let dictionary = newValue {
                parse(dictionary: dictionary)
            }
        }
    }

    open var thinned: [String: Any]? {
        return json
    }

    open func parse(dictionary: [String: Any]) {
        if !((data as NSDictionary?)?.isEqual(to: dictionary) ?? false) {
            var keys = Set<String>(dictionary.keys)
            if let data = data {
                keys = keys.union(data.keys)
            }

            for key in keys {
                willChangeValue(forKey: key)
            }
            data = DictionaryUtils.merge(data, with: dictionary)?.filter {
                !($0.value is NSNull)
            }
            for key in keys {
                didChangeValue(forKey: key)
            }
        }
    }

    open var displayTitle: String? {
        return parser.asString(self.data?["title"])
    }

    override public required init() {
        super.init()
    }

    override open func value(forUndefinedKey key: String) -> Any? {
        return data?[key]
    }

    override open func setValue(_ value: Any?, forUndefinedKey key: String) {
        willChangeValue(forKey: key)
        willChangeValue(forKey: "data")
        force.data?[key] = value
        didChangeValue(forKey: "data")
        didChangeValue(forKey: key)
    }

    override open func isEqual(_ object: Any?) -> Bool {
        if let entity = object as? DictionaryEntity {
            if let data = data {
                if let data2 = entity.data {
                    return NSDictionary(dictionary: data).isEqual(to: data2)
                } else {
                    return false
                }
            } else {
                return entity.data == nil
            }
        }
        return false
    }

    open func copy() -> Self {
        let copy = Self()
        copy.data = data
        return copy
    }
}

public extension DictionaryEntity {
    func set(key: String, value: Any?, notify: String? = nil) {
        run({ [weak self] in
            self?.force.data?[key] = value
        }, notify: notify ?? key)
    }
}
