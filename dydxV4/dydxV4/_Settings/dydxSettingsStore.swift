//
//  dydxSettingsStore.swift
//  dydxV4
//
//  Created by Michael Maguire on 4/8/24.
//  Copyright © 2024 dYdX Trading Inc. All rights reserved.
//

import Utilities
import dydxPresenters

class dydxSettingsStore: DebugSettingsStore {
    init() {
        super.init(tag: "Settings")
        for key in dydxSettingsStoreKey.allCases {
            if value(forKey: key.rawValue) == nil {
                setValue(key.defaultValue, forKey: key.rawValue)
            }
        }
    }
}
