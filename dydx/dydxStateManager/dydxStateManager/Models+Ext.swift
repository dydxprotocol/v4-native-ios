//
//  Models+Ext.swift
//  dydxStateManager
//
//  Created by Rui Huang on 10/2/22.
//

import Foundation
import Abacus
import Utilities

extension ParsingError: Error {
    public var localizedMessage: String? {
        if let stringKey = stringKey {
            return DataLocalizer.localize(path: stringKey)
        }
        return message
    }

    public static let unknown = ParsingError(type: .unhandled, message: "", stringKey: "APP.GENERAL.UNKNOWN_ERROR", stackTrace: nil, codespace: nil)
}

public extension TradeInput {
    var selectedTypeText: String? {
        let typeOptions = options?.typeOptions
        if let selectedType = typeOptions?.first(where: { $0.type == type?.rawValue }), let stringKey = selectedType.stringKey {
            return DataLocalizer.localize(path: stringKey)
        } else {
            return nil
        }
    }
}

public extension OrderSide {
    var opposite: Abacus.PositionSide {
        switch self {
        case .buy: return .short_
        case .sell: return .long_
        default: return .short_
        }
    }
}

public extension GasToken {
    static func from(tokenName: String) -> GasToken? {
        switch tokenName {
        case "USDC": return GasToken.usdc
        case "NATIVE": return GasToken.native
        default: return nil
        }
    }
}
