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
    case isVaultEnabled = "ff_vault_enabled"
    case showPredictionMarketsUI = "ff_show_prediction_markets_ui"
    case abacus_static_typing
    case metadata_service

    var defaultValue: Bool {
        switch self {
        case .force_mainnet:
            return false
        case .enable_app_rating:
            return true
        case .isVaultEnabled:
            return true
        case .showPredictionMarketsUI:
            return false
        case .abacus_static_typing:
            return true
        case .metadata_service:
            return true
        }
    }

    /// dumps the state of remote as local currently knows it to be.
    public static var remoteState: [String: Bool] {
        allCases.reduce(into: [String: Bool]()) { result, flag in
            result[flag.rawValue] = flag.isEnabledOnRemote
        }
    }

    private var isEnabledOnRemote: Bool? {
        FeatureService.shared?.isOn(feature: rawValue)
    }

    public var isEnabled: Bool {
        if FeatureService.shared == nil {
            Console.shared.log("WARNING: FeatureService not yet set up.")
        }
        return isEnabledOnRemote ?? defaultValue
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
