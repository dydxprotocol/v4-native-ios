//
//  DebugSettingsStore.swift
//  Utilities
//
//  Created by Rui Huang on 3/31/23.
//  Copyright © 2023 dYdX Trading Inc. All rights reserved.
//

import Foundation

open class DebugSettingsStore: UserDefaultsStore, DebugProtocol {
    public var debug: [String: Any]? {
        get {
            dictionary
        }
        set {
            dictionary = newValue
        }
    }
}
