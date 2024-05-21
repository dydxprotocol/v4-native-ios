//
//  dydxSelectedMarketsStore.swift
//  dydxPresenters
//
//  Created by Michael Maguire on 3/14/24.
//

import Foundation
import Utilities

public final class dydxSelectedMarketsStore {
    private let storeKey = "last_selected_market"
    public static let shared = dydxSelectedMarketsStore()

    public var lastSelectedMarket: String {
        get { SettingsStore.shared?.value(forKey: storeKey) as? String ?? "ETH-USD" }
        set { SettingsStore.shared?.setValue(newValue, forKey: storeKey) }
    }
}
