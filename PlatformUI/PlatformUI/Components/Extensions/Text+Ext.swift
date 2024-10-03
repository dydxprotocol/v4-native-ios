//
//  Text+Ext.swift
//  PlatformUI
//
//  Created by Michael Maguire on 4/1/24.
//

import SwiftUI
import Utilities

public extension Text {
    init(localizerPathKey: String, params: [String: String]? = nil) {
        self = Text(DataLocalizer.shared?.localize(path: localizerPathKey, params: params) ?? "")
    }
}
