//
//  VaultTransferType.swift
//  
//
//  Created by Rui Huang on 12/05/2025.
//

import dydxViews
import dydxAnalytics

extension VaultTransferType {
    var analyticsInputType: AnalyticsEventV2.VaultAnalyticsInputType {
        switch self {
        case .deposit: return .deposit
        case .withdraw: return .withdraw
        }
    }
}
