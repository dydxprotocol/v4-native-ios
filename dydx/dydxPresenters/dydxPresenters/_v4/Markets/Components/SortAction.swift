//
//  SortAction.swift
//  dydxPresenters
//
//  Created by Rui Huang on 15/11/2024.
//

import Utilities
import PlatformUI
import Abacus
import dydxStateManager
import dydxFormatter

// MARK: Sorting

struct SortAction: Equatable {
    static var defaultAction: SortAction {
        SortAction(type: .volume24h,
                   text: DataLocalizer.localize(path: "APP.TRADE.VOLUME"),
                   action: { first, second  in
                       first.perpetual?.volume24H?.doubleValue ?? 0 > second.perpetual?.volume24H?.doubleValue ?? 0
                   })
    }

    static var actions: [SortAction] {
        [
            .defaultAction,
            SortAction(type: .gainers,
                       text: DataLocalizer.localize(path: "APP.GENERAL.GAINERS"),
                       action: { first, second  in
                           first.priceChange24HPercent?.doubleValue ?? 0 > second.priceChange24HPercent?.doubleValue ?? 0
                       }),

            SortAction(type: .losers,
                       text: DataLocalizer.localize(path: "APP.GENERAL.LOSERS"),
                       action: { first, second  in
                           first.priceChange24HPercent?.doubleValue ?? 0 < second.priceChange24HPercent?.doubleValue ?? 0
                       }),

            SortAction(type: .fundingRate,
                       text: DataLocalizer.localize(path: "APP.GENERAL.FUNDING_RATE_CHART_SHORT"),
                       action: { first, second  in
                           first.perpetual?.nextFundingRate?.doubleValue ?? 0 > second.perpetual?.nextFundingRate?.doubleValue ?? 0
                       }),

            SortAction(type: .name,
                       text: DataLocalizer.localize(path: "APP.GENERAL.NAME"),
                       action: { first, second  in
                           first.market ?? "" < second.market ?? ""
                       }),

            SortAction(type: .price,
                       text: DataLocalizer.localize(path: "APP.GENERAL.PRICE"),
                       action: { first, second  in
                           first.oraclePrice?.doubleValue ?? 0 > second.oraclePrice?.doubleValue ?? 0
                       })
        ]
    }

    private let type: MarketSorting
    let text: String
    let action: ((PerpetualMarket, PerpetualMarket) -> Bool)

    static func == (lhs: SortAction, rhs: SortAction) -> Bool {
        lhs.type == rhs.type
    }
}

enum MarketSorting: Equatable {
    case name
    case marketCap
    case volume24h
    case change24h
    case openInterest
    case fundingRate
    case price
    case gainers
    case losers
}
