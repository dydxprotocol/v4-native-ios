//
//  BrowsingListInteractor.swift
//  InteractorLib
//
//  Created by Qiang Huang on 11/10/18.
//  Copyright © 2018 dYdX. All rights reserved.
//

import ParticlesKit
import Utilities

@objc open class BrowsingListInteractor: FilteredListInteractor {
    @objc open dynamic var dataCache: DataPoolInteractor? {
        didSet {
            didSetDataCache(oldValue: oldValue)
        }
    }

    @objc open private(set) dynamic var isLoading: Bool = false {
        didSet {
            didSetIsLoading(oldValue: oldValue)
        }
    }

    @objc open dynamic var isReady: Bool = false {
        didSet {
            didSetIsReady(oldValue: oldValue)
        }
    }

    @objc override open dynamic var data: [ModelObjectProtocol]? {
        if let values = map?.transformed?.values {
            return Array(values)
        } else {
            return sequential?.sequenceTransformed
        }
    }

    @objc open private(set) dynamic var map: DataPoolInteractor? {
        didSet {
            didSetMap(oldValue: oldValue)
        }
    }

    @objc open private(set) dynamic var sequential: DataPoolInteractor? {
        didSet {
            didSetSequential(oldValue: oldValue)
        }
    }

    open func didSetDataCache(oldValue: DataPoolInteractor?) {
        if dataCache !== oldValue {
            if dataCache?.sequential ?? false {
                map = nil
                sequential = dataCache
            } else {
                sequential = nil
                map = dataCache
            }
        }
    }

    open func didSetMap(oldValue: DataPoolInteractor?) {
        changeObservation(from: oldValue, to: map, keyPath: #keyPath(DataPoolInteractor.data)) { [weak self] _, _, _, _ in
            self?.dataChanged()
        }
        changeObservation(from: oldValue, to: map, keyPath: #keyPath(DataPoolInteractor.isLoading)) { [weak self] _, _, _, _ in
            self?.isLoading = self?.map?.isLoading ?? false
        }
    }

    open func didSetSequential(oldValue: DataPoolInteractor?) {
        changeObservation(from: oldValue, to: sequential, keyPath: #keyPath(DataPoolInteractor.sequence)) { [weak self] _, _, _, _ in
            self?.sequentialChanged()
        }
        changeObservation(from: oldValue, to: sequential, keyPath: #keyPath(DataPoolInteractor.isLoading)) { [weak self] _, _, _, _ in
            self?.isLoading = self?.sequential?.isLoading ?? false
        }
    }

    open func didSetIsLoading(oldValue: Bool) {
        updateIsReady()
    }

    open func didSetIsReady(oldValue: Bool) {
    }

    open func updateIsReady() {
        if isLoading {
            isReady = (list?.count ?? 0) > 0
        } else {
            isReady = true
        }
    }

    override open func sync(_ list: [ModelObjectProtocol]?) {
        super.sync(list)
        updateIsReady()
    }

    open func dataChanged() {
        filter()
    }

    open func sequentialChanged() {
        filter()
    }

    override open func filter(data: ModelObjectProtocol, key: String, value: Any) -> Bool {
        switch key {
        default:
            return true
        }
    }

    override open func sort(data: [ModelObjectProtocol]?) -> [ModelObjectProtocol]? {
        if sequential != nil {
            return data
        } else {
            return super.sort(data: data)
        }
    }
}
