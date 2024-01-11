//
//  DebugEnabled.swift
//  Utilities
//
//  Created by Rui Huang on 8/30/23.
//  Copyright © 2023 dYdX Trading Inc. All rights reserved.
//

import Foundation

public struct DebugEnabled {
    public static let key = "debug.enabled"

    public static var enabled: Bool {
    #if DEBUG
        true
    #else
        !Installation.appStore && UserDefaults.standard.bool(forKey: key)
    #endif
    }
}
