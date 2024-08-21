//
//  dydxFavoriteStore.swift
//  dydxPresenters
//
//  Created by Rui Huang on 4/24/23.
//

import Foundation
import Utilities

final class dydxFavoriteStore {
    private let settingsStore = SettingsStore.shared
    private let storeKey = "favorite_markets"

    func isFavorite(marketId: String) -> Bool {
        let marketIdList = settingsStore?.value(forKey: storeKey) as? [String] ?? []
        return marketIdList.contains(marketId)
    }

    func setFavorite(isFavorite: Bool, marketId: String) {
        var marketIdList = settingsStore?.value(forKey: storeKey) as? [String] ?? []
        if isFavorite {
            if marketIdList.contains(marketId) == false {
                marketIdList.append(marketId)
                settingsStore?.setValue(marketIdList, forKey: storeKey)
            }
        } else {
            if let index = marketIdList.firstIndex(of: marketId) {
                marketIdList.remove(at: index)
                settingsStore?.setValue(marketIdList, forKey: storeKey)
            }
        }
    }
}
