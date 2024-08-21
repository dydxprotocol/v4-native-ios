//
//  KeyedDataInteractor.swift
//  ParticlesKit
//
//  Created by Qiang Huang on 10/9/20.
//  Copyright © 2020 dYdX. All rights reserved.
//

import Utilities

@objc open class KeyedDataInteractor: DataPoolInteractor {
    @objc public dynamic var filter: String? {
        didSet {
            if filter != oldValue {
                filterChanged()
            }
        }
    }

    @objc open dynamic var list: ListInteractor?

    var transformDebouncer: Debouncer = Debouncer()

    open func filterChanged() {
        transformedChanged()
    }

    open func transformedChanged() {
        let transformed = self.transformed
        var filtered: [String: ModelObjectProtocol]?
        var sorted: [ModelObjectProtocol]?

        let handler = transformDebouncer.debounce()
        handler?.run(background: { [weak self] in
            if let self = self {
                filtered = self.filter(objects: transformed, filter: self.filter)
            }
        }, then: { [weak self] in
            if let self = self {
                sorted = self.sort(objects: filtered)
            }
        }, final: { [weak self] in
            if let self = self {
                if let sorted = sorted { let list = self.list ?? ListInteractor()
                    list.sync(sorted)
                    self.list = list
                } else {
                    self.list = nil
                }
            }
        }, delay: 0.1)
    }

    open func filter(objects: [String: ModelObjectProtocol]?, filter: String?) -> [String: ModelObjectProtocol]? {
        let filter = filter?.lowercased().trim()
        return transformed?.compactMapValues({ (object) -> ModelObjectProtocol? in
            self.filter(object: object, lowercased: filter) ? object : nil
        })
    }

    open func sort(objects: [String: ModelObjectProtocol]?) -> [ModelObjectProtocol]? {
        return objects?.values.sorted(by: { (object1, object2) -> Bool in
            object1.order?(ascending: object2) ?? true
        })
    }

    open func filter(object: ModelObjectProtocol, lowercased filter: String?) -> Bool {
        return (object as? FilterableProtocol)?.filter(lowercased: filter) ?? false
    }
}
