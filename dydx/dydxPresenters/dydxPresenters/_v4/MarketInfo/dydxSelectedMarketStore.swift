//
//  dydxSelectedMarketsStore.swift
//  dydxPresenters
//
//  Created by Michael Maguire on 3/14/24.
//

import Foundation
import Utilities

final class dydxSelectedMarketsStore {
    private let storeKey = "last_selected_market"
    static let shared = dydxSelectedMarketsStore()

    var lastSelectedMarket: String {
        get { SettingsStore.shared?.value(forKey: storeKey) as? String ?? "ETH-USD" }
        set { SettingsStore.shared?.setValue(newValue, forKey: storeKey) }
    }
}
