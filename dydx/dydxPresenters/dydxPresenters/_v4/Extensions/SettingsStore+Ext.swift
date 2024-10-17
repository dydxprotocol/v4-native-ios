//
//  SettingsStore+Ext.swift
//  dydxPresenters
//
//  Created by Michael Maguire on 10/17/24.
//

import Utilities

extension KeyValueStoreProtocol {
    func value(forDydxKey key: dydxSettingsStoreKey) -> Any? {
        self.value(forKey: key.rawValue)
    }

    func setValue(_ value: Any?, forDydxKey key: dydxSettingsStoreKey) {
        self.setValue(value, forKey: key.rawValue)
    }
}
