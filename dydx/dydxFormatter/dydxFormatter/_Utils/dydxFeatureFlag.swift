//
//  dydxFeatureFlag.swift
//  dydxModels
//
//  Created by Rui Huang on 6/6/22.
//  Copyright © 2022 dYdX Trading Inc. All rights reserved.
//

import Foundation
import Utilities
import Statsig

public enum dydxStatsigFeatureFlags: String {
    case useSkip = "ff_skip_migration"

    /// note this is always defaults to false if the feature flag does not exist in stat sig
    /// see https://docs.statsig.com/client/iosClientSDK#checking-a-gate
    public var isEnabled: Bool {
        Statsig.checkGate(self.rawValue)
    }
}

public enum dydxBoolFeatureFlag: String, CaseIterable {
    case push_notification
    case force_mainnet
    case enable_app_rating

    private static let obj = NSObject()

    public var isEnabled: Bool {
        if FeatureService.shared == nil {
            Console.shared.log("WARNING: FeatureService not yet set up.")
        }
        switch self {
        case .enable_app_rating:
            return Self.obj.parser.asBoolean(FeatureService.shared?.flag(feature: rawValue))?.boolValue ?? true
        case .push_notification, .force_mainnet:
            return Self.obj.parser.asBoolean(FeatureService.shared?.flag(feature: rawValue))?.boolValue ?? false
        }
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
        if FeatureService.shared == nil {
            Console.shared.log("WARNING: FeatureService not yet set up.")
        }
        return Self.obj.parser.asString(FeatureService.shared?.flag(feature: rawValue))
    }
}

public enum dydxNumberFeatureFlag: String {
    case _place_holder

    private static let obj = NSObject()

    public var number: NSNumber? {
        if FeatureService.shared == nil {
            Console.shared.log("WARNING: FeatureService not yet set up.")
        }
        return Self.obj.parser.asNumber(FeatureService.shared?.flag(feature: rawValue))
    }
}
