//
//  FilterEntity.swift
//  EntityLib
//
//  Created by Qiang Huang on 10/23/18.
//  Copyright © 2018 dYdX. All rights reserved.
//

import Foundation

open class FilterEntity: DictionaryEntity {
    private var key: String?
    private var preferenceKey: String? {
        if let key = key {
            return "\(type(of: self)).filters.\(key)"
        }
        return nil
    }

    open override var data: [String: Any]? {
        didSet {
            if let preferenceKey = preferenceKey {
                UserDefaults.standard.set(data, forKey: preferenceKey)
            }
        }
    }

     public required init() {
        super.init()
    }

    public init(key: String) {
        self.key = key
        super.init()

        if let preferenceKey = preferenceKey {
            data = UserDefaults.standard.dictionary(forKey: preferenceKey) ?? [String: Any]()
        }
    }

    public init(copy entity: FilterEntity) {
        super.init()
        data = entity.data
    }

    public func apply(to entity: FilterEntity) {
        entity.data = data
    }
}
