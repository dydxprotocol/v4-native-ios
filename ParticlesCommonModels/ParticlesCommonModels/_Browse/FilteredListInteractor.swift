//
//  FilteredListInteractor.swift
//  InteractorLib
//
//  Created by Qiang Huang on 10/26/18.
//  Copyright © 2018 dYdX. All rights reserved.
//

import ParticlesKit
import Utilities

// interactor is responsible for loading/transforming/assembling data
@objc open class FilteredListInteractor: ListInteractor, FilteredListInteractorProtocol {
    @IBInspectable public var directFiltering: Bool = false
    private var debouncer: Debouncer = Debouncer()

    override open var loading: Bool {
        didSet {
            if loading != oldValue {
                status = loading ? LoadingStatus.shared : nil
            }
        }
    }

    private var status: LoadingStatus? {
        didSet {
            if status !== oldValue {
//                oldValue?.minus()
//                status?.plus()
            }
        }
    }

    @objc public dynamic var onlyShowLiked: Bool = false {
        didSet {
            if onlyShowLiked != oldValue {
                filter()
            }
        }
    }

    public var liked: LikedObjectsProtocol? {
        didSet {
            changeObservation(from: oldValue, to: liked, keyPath: #keyPath(LikedKeysInteractor.liked)) { [weak self] _, _, _, _ in
                self?.likedChanged()
            }

            changeObservation(from: oldValue, to: liked, keyPath: #keyPath(LikedKeysInteractor.disliked)) { [weak self] _, _, _, _ in
                self?.filter()
            }
        }
    }

    public var filters: FilterEntity? {
        didSet {
            changeObservation(from: oldValue, to: filters, keyPath: #keyPath(FilterEntity.data)) { [weak self] _, _, _, _ in
                self?.filter()
            }
        }
    }

    open var data: [ModelObjectProtocol]? {
        return nil
    }

    open var filterText: String? {
        didSet {
            if filterText != oldValue {
                filter()
            }
        }
    }

    open var filterFields: [String]? {
        return nil
    }

    deinit {
        loading = false
    }

    open func likedChanged() {
        if onlyShowLiked {
            filter()
        }
    }

    open func filter(data: [ModelObjectProtocol]?) -> [ModelObjectProtocol]? {
        let filterText = self.filterText?.lowercased().trim()
        return data?.filter({ (item: ModelObjectProtocol) -> Bool in
            let key = key(obj: item)
            if self.onlyShowLiked, let key = key {
                if self.liked?.liked?.contains(key) ?? false {
                    return self.filter(data: item, text: filterText, filters: self.filters?.data)
                }
            } else if let key = key, self.liked?.disliked?.contains(key) ?? false {
                return false
            } else {
                return self.filter(data: item, text: filterText, filters: self.filters?.data)
            }
            return false
        })
    }

    private func key(obj: ModelObjectProtocol) -> String? {
        if let key = obj.key {
            return key
        } else {
            return nil
        }
    }

    open func filter() {
        if directFiltering {
            if let data = prefilter(data: data) {
                loading = true
                let filtered = filter(data: data)
                let grouped = group(data: filtered)
                let sorted = sort(data: grouped)
                finalize(data: sorted)
                loading = false
            } else {
                finalize(data: nil)
            }
        } else {
            if let data = prefilter(data: data) {
                loading = true
                var filtered: [ModelObjectProtocol]?
                var grouped: [ModelObjectProtocol]?
                var sorted: [ModelObjectProtocol]?
                debouncer.debounce()?.run(background: { [weak self] in
                    filtered = self?.filter(data: data)
                }, then: { [weak self] in
                    grouped = self?.group(data: filtered)
                }, then: { [weak self] in
                    sorted = self?.sort(data: grouped)
                }, final: { [weak self] in
                    self?.finalize(data: sorted)
                    self?.loading = false
                }, delay: 0.0)
            } else {
                debouncer.debounce()?.run({ [weak self] in
                    self?.finalize(data: nil)
                }, delay: 0.0)
            }
        }
    }

    open func prefilter(data: [ModelObjectProtocol]?) -> [ModelObjectProtocol]? {
        return data
    }

    open func filter(data: ModelObjectProtocol, text: String?, filters: [String: Any]?) -> Bool {
        return filter(data: data, text: text) && filter(data: data, filters: filters)
    }

    open func filter(data: ModelObjectProtocol, text: String?) -> Bool {
        if let filteredObject = data as? FilteredObjectProtocol {
            return filteredObject.filter(text: text)
        } else {
            if let lowercased = text?.trim()?.lowercased(), let dictionary = (data as? DictionaryEntity)?.force.data {
                if let filterFields = filterFields {
                    if let _ = filterFields.first(where: { (filterField: String) -> Bool in
                        if let data = data as? NSObject, let string = parser.asString(data.value(forKey: filterField))?.lowercased() {
                            return string.contains(lowercased)
                        }
                        return false
                    }) {
                        return true
                    }
                } else {
                    if let _ = dictionary.values.first(where: { (value: Any) -> Bool in
                        if let string = (value as? String)?.lowercased() {
                            return string.contains(lowercased)
                        }
                        return false
                    }) {
                        return true
                    }
                }
                return false
            }
            return true
        }
    }

    open func filter(data: ModelObjectProtocol, filters: [String: Any]?) -> Bool {
        if let filters = filters {
            var ok = true
            for (key, value) in filters {
                let lowercased = (value as? String)?.lowercased().components(separatedBy: ",")
                if !filter(data: data, key: key, value: lowercased ?? value) {
                    ok = false
                    break
                }
            }
            return ok
        }
        return true
    }

    open func filter(data: ModelObjectProtocol, key: String, value: Any) -> Bool {
        guard let data = data as? (NSObject & ModelObjectProtocol) else {
            return false
        }
        if let strings = value as? [String] {
            if let value = parser.asString(data.value(forKey: key)) {
                return strings.first(where: { (string) -> Bool in
                    value.contains(string)
                }) != nil
            }
        } else if let string = value as? String {
            if let value = parser.asString(data.value(forKey: key)) {
                return value.contains(string)
            }
        } else if let int = value as? Int {
            if let value = parser.asNumber(data.value(forKey: key))?.intValue {
                return value == int
            }
        } else if let float = value as? Float {
            if let value = parser.asNumber(data.value(forKey: key))?.floatValue {
                return value == float
            }
        } else if let bool = value as? Bool {
            if let value = parser.asNumber(data.value(forKey: key))?.boolValue {
                return value == bool
            }
        }
        return false
    }

    open func group(data: [ModelObjectProtocol]?) -> [ModelObjectProtocol]? {
        return data
    }

    open func sort(data: [ModelObjectProtocol]?) -> [ModelObjectProtocol]? {
        return data?.sorted(by: { (data1, data2) -> Bool in
            data1.order?(ascending: data2) ?? true
        })
    }

    open func finalize(data: [ModelObjectProtocol]?) {
        sync(data)
    }
}
