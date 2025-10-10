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
    case showPredictionMarketsUI = "ff_show_prediction_markets_ui"
    case simple_ui = "ff_simple_ui"
    case privy_ios = "ff_privy_ios"
    case turnkey_ios = "ff_turnkey_ios"
    case turnkey_ios_apple = "ff_turnkey_ios_apple"
    case rewards_sep_2025 = "ff_rewards_sep_2025"
    case fiat_deposit = "ff_fiat_deposit"

    var defaultValue: Bool {
        switch self {
        case .force_mainnet:
            return false
        case .showPredictionMarketsUI:
            return false
        case .simple_ui:
            return true
        case .privy_ios:
            return false
        case .turnkey_ios:
            return true
        case .turnkey_ios_apple:
            return false
        case .rewards_sep_2025:
            return false
        case .fiat_deposit:
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

public enum dydxNumberFeatureFlag: String {
    case min_deposit_for_launchable_market
    case min_usdc_for_deposit

    // min/max of Skip Go Fast amount; hardcoded on Skip's end
    case skip_ga_fast_transfer_min
    case skip_go_fast_transfer_max

    var defaultValue: Double {
        switch self {
        case .min_deposit_for_launchable_market:
            return 10000.0
        case .min_usdc_for_deposit:
            return  Installation.source == .debug ? 1.0 : 10.0
        case .skip_ga_fast_transfer_min:
            return 100.0
        case .skip_go_fast_transfer_max:
            return 100000.0
        }
    }

    public var value: Double {
        if FeatureService.shared == nil {
            Console.shared.log("WARNING: FeatureService not yet set up.")
        }
        return FeatureService.shared?.value(store: "v4_params", feature: rawValue, defaultValue: defaultValue) ?? defaultValue
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

public enum dydxTurnkeyDepositParam: String {
    case eth_min_slow
    case eth_min_fast
    case eth_max
    case default_min_slow
    case default_min_fast
    case default_max

    public var string: String {
        FeatureService.shared?.value(store: "v4_params", feature: rawValue, defaultValue: "-") ?? "-"
    }
}

public enum dydxFiatDepositParam: String {
    case moonpay_fee_percent
    case moonpay_min_deposit

    public var value: Double {
        FeatureService.shared?.value(store: "v4_params", feature: rawValue, defaultValue: 0.0) ?? 0
    }
}

public enum dydxRewardsParam: String {
    case rewards_dollar_amount
    case rewards_fee_rebate_percent

    public var string: String {
        FeatureService.shared?.value(store: "v4_params", feature: rawValue, defaultValue: "-") ?? "-"
    }
}
