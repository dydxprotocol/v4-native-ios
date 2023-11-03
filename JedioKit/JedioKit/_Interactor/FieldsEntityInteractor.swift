//
//  FieldsEntityListInteractor.swift
//  JedioKit
//
//  Created by Qiang Huang on 9/2/19.
//  Copyright © 2019 dYdX. All rights reserved.
//

import ParticlesKit
import Utilities

open class FieldsEntityInteractor: BaseInteractor, InteractorProtocol {
    @IBOutlet open var fieldLoader: FieldLoader? {
        didSet {
            changeObservation(from: oldValue, to: fieldLoader, keyPath: #keyPath(FieldLoader.definitionFile)) { [weak self] _, _, _, _ in
                if let self = self {
                    self.definitionGroups = self.fieldLoader?.definitionGroups
                }
            }
        }
    }

    @objc public dynamic var definitionGroups: [FieldDefinitionGroup]? {
        didSet {
            loadFields()
        }
    }

    @IBOutlet open var list: ListInteractor? {
        didSet {
            if list !== oldValue {
                loadFields()
            }
        }
    }

    open var entity: ModelObjectProtocol? {
        didSet {
            if entity !== oldValue {
                if entity != nil {
                    loadFields()
                }
                let dictionaryEntity = entity as? DictionaryEntity
                changeObservation(from: oldValue, to: dictionaryEntity, keyPath: #keyPath(DictionaryEntity.data)) { [weak self] _, _, _, _ in
                    self?.filter()
                }
            }
        }
    }

    open var groups: [FieldListInteractor]? {
        didSet {
            if groups != oldValue {
                filter()
            }
        }
    }

    private var filtered: [FieldListInteractor]? {
        didSet {
            if filtered != oldValue {
                updateSections()
            }
        }
    }

    open var data: [String: Any]? {
        if let filtered = filtered {
            var data = [String: Any]()
            for section in filtered {
                if let fields = section.list {
                    for field in fields {
                        if let field = field as? FieldInput, let key = field.fieldName, let value = field.value {
                            data[key] = value
                        }
                    }
                }
            }
            return data
        }
        return nil
    }

    open var keys: [String]? {
        if let groups = groups {
            var keys = [String]()
            for group in groups {
                if let list = group.list {
                    for item in list {
                        if let field = item as? FieldProtocol, let key = field.field?.definition(for: "field")?["field"] as? String {
                            keys.append(key)
                        }
                    }
                }
            }
            return keys
        }
        return nil
    }

    open func loadFields() {
        if let definitionGroups = definitionGroups, let list = list, let entity = entity {
            list.parent = entity
            let groups = definitionGroups.compactMap({ (definitionGroup: FieldDefinitionGroup) -> FieldListInteractor? in
                let group = FieldListInteractor()
                group.title = definitionGroup.title
                group.definitionGroup = definitionGroup
                group.list = definitionGroup.transformToFieldData(entity: entity)
                return (group.list?.count != 0) ? group : nil
            })
            self.groups = groups
        }
    }

    public func filter() {
        if let groups = groups {
            var filteredList: [FieldListInteractor] = []
            for i in 0 ..< groups.count {
                let group = groups[i]
                var trimmed: FieldListInteractor?
                if let filtered = filtered, i < filtered.count {
                    trimmed = filtered[i]
                } else {
                    trimmed = FieldListInteractor()
                }
                if let trimmed = trimmed {
                    trimmed.title = group.title
                    trimmed.definitionGroup = group.definitionGroup
                    trimmed.list = filter(fields: group.list as? [FieldProtocol], definitions: group.definitionGroup)
                    filteredList.append(trimmed)
                }
            }
            filtered = filteredList
        }
    }

    public func filter(fields: [FieldProtocol]?, definitions: FieldDefinitionGroup?) -> [FieldProtocol]? {
        if let fields = fields, let definitions = definitions, let entity = entity {
            return fields.filter { (field) -> Bool in
                definitions.shouldShow(entity: entity, field: field)
            }
        } else {
            return nil
        }
    }

    public func updateSections() {
        if let filtered = filtered {
            let notEmpty = filtered.compactMap { (section) -> FieldListInteractor? in
                (section.list?.count ?? 0) != 0 ? section : nil
            }
            list?.sync(notEmpty)
        } else {
            list?.sync(nil)
        }
    }

    public func refresh() {
        if let filtered = filtered, let groups = groups, filtered.count == groups.count {
            for i in 0 ..< filtered.count {
                let list = filtered[i]
                let group = groups[i]
                list.sync(filter(fields: group.list as? [FieldProtocol], definitions: list.definitionGroup))
            }
            updateSections()
        }
    }

    open func validateInput() -> Error? {
        if let filtered = filtered {
            var error: Error?
            _ = filtered.first { (list) -> Bool in
                if let fields = list.list {
                    _ = fields.first { (field) -> Bool in
                        if let field = field as? FieldInput {
                            error = field.validate()
                            return error != nil
                        }
                        return false
                    }
                }
                return error != nil
            }
            return error
        }
        return nil
    }
}
