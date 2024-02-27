//
//  dydxDebugSettingsStore.swift
//  dydxV4
//
//  Created by Michael Maguire on 7/14/23.
//  Copyright © 2023 dYdX Trading Inc. All rights reserved.
//

import Foundation
import Utilities
import dydxViews

class dydxDebugSettingsStore: DebugSettingsStore {
    static let defaultValues: [String: String?] = [
        "language": DataLocalizer.shared?.language,
        "v4_theme": dydxThemeType.dark.rawValue,
        // whether green or red is the positive direction
        "direction_color_preference": "green_is_up"
    ]
}
