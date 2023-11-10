//
//  dydxFeatureFlag.swift
//  dydxModels
//
//  Created by Rui Huang on 6/6/22.
//  Copyright © 2022 dYdX Trading Inc. All rights reserved.
//

import Foundation
import Utilities

public enum dydxBoolFeatureFlag: String, CaseIterable {
    case push_notification
    case full_story
    case force_mainnet

    private static let obj = NSObject()

    public var isEnabled: Bool {
        Self.obj.parser.asBoolean(FeatureService.shared?.flag(feature: rawValue))?.boolValue ?? false
    }

    public static var enabledFlags: [String] {
        Self.allCases.compactMap { flag in
            flag.isEnabled ? flag.rawValue : nil
        }
    }
}

public enum dydxStringFeatureFlag: String {
    case deployment_url

    private static let obj = NSObject()

    public var string: String? {
        Self.obj.parser.asString(FeatureService.shared?.flag(feature: rawValue))
    }
}

public enum dydxNumberFeatureFlag: String {
    case _place_holder

    private static let obj = NSObject()

    public var number: NSNumber? {
        Self.obj.parser.asNumber(FeatureService.shared?.flag(feature: rawValue))
    }
}
