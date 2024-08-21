//
//  LocalSavedSearchCacheInteractor.swift
//  InteractorLib
//
//  Created by Qiang Huang on 10/30/18.
//  Copyright © 2018 dYdX. All rights reserved.
//

import ParticlesKit

@objc open class LocalSavedSearchCacheInteractor: DataListInteractor, SavedSearchesProtocol {
    @objc public dynamic var savedSearches: [SavedSearchEntity]? {
        get { return data as? [SavedSearchEntity] }
        set { data = newValue }
    }

    public func add(name: String, search: String?, filters: [String: Any]?) {
        var savedSearches = self.savedSearches ?? [SavedSearchEntity]()
        let savedSearch = SavedSearchEntity()
        savedSearch.name = name
        savedSearch.text = search
        savedSearch.filters = filters
        savedSearches.append(savedSearch)
        self.savedSearches = savedSearches

        loader?.save(object: data)
    }

    public func remove(savedSearch: SavedSearchEntity) {
        var savedSearches = self.savedSearches
        if let index = savedSearches?.firstIndex(where: { (item: SavedSearchEntity) -> Bool in
            item === savedSearch
        }) {
            savedSearches?.remove(at: index)
        }
        self.savedSearches = savedSearches
    }
}
