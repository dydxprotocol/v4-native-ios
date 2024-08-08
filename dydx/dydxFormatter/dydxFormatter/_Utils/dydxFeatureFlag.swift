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
    case force_mainnet
    case enable_app_rating
    case shouldUseSkip = "ff_skip_migration"
    case isVaultEnabled = "ff_vault_enabled"

    var defaultValue: Bool {
        switch self {
        case .force_mainnet:
            return false
        case .enable_app_rating:
            return true
        case .shouldUseSkip:
            return true
        case .isVaultEnabled:
            return false
        }
    }

    private static let obj = NSObject()

    public var isEnabled: Bool {
        if FeatureService.shared == nil {
            Console.shared.log("WARNING: FeatureService not yet set up.")
        }
//        if let statsigValue = FeatureService.shared?.isOn(feature: rawValue) {
//            Tracking.shared?.setUserInfo(key: self.rawValue, value: statsigValue)
//            return isEnabled
//        }
        return FeatureService.shared?.isOn(feature: rawValue) ?? defaultValue
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
        return FeatureService.shared?.value(feature: rawValue)
    }
}

//public extension TrackingProtocol {
//    func set(userProperty: UserProperty, toValue value: Any) {
//        switch userProperty {
//        case .walletAddress, .walletType, .network, .selectedLocale, .dydxAddress, .subaccountNumber:
//            userInfo?[userProperty.key] = value
//        case .statsigConfig(let flag):
//            if let existingInfo = userInfo?[userProperty.key] as? [String: Any] {
//                userInfo?[flag.rawValue] = value
//            } else {
//                userInfo?[userProperty.key] = [flag.rawValue: value]
//            }
//        }
//    }
//}
