//
//  dydxTokenConstants.swift
//  dydxPresenters
//
//  Created by Rui Huang on 10/10/23.
//

import Foundation
import dydxStateManager

struct dydxTokenConstants {
    static let usdcTokenKey = "usdc"
    static let nativeTokenKey = "chain"

    static var usdcTokenName: String {
        AbacusStateManager.shared.environment?.tokens[dydxTokenConstants.usdcTokenKey]?.name ?? "USDC"
    }

    static var usdcTokenLogoUrl: URL? {
        if let imageUrl = AbacusStateManager.shared.environment?.tokens[dydxTokenConstants.usdcTokenKey]?.imageUrl {
            return URL(string: imageUrl)
        } else {
            return nil
        }
    }

    static var nativeTokenName: String {
        AbacusStateManager.shared.environment?.tokens[dydxTokenConstants.nativeTokenKey]?.name ?? "DYDX"
    }

    static var nativeTokenLogoUrl: URL? {
        if let imageUrl = AbacusStateManager.shared.environment?.tokens[dydxTokenConstants.nativeTokenKey]?.imageUrl {
            return URL(string: imageUrl)
        } else {
            return nil
        }
    }
}
