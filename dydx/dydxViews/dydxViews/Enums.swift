//
//  Enums.swift
//  dydxViews
//
//  Created by Rui Huang on 2/27/23.
//

import Foundation

public enum OrderSide {
    case unknown
    case BUY
    case SELL
}

public enum OrderType {
    case unknown
    case MARKET
    case LIMIT
    case STOP_LIMIT
    case TRAILING_STOP
    case TAKE_PROFIT
    case LIQUIDATED
    case LIQUIDATION
    case STOP_MARKET
    case TAKE_PROFIT_MARKET
}

public enum FillLiquidity {
    case unknown
    case MAKER
    case TAKER
}

public enum TransferStatus {
   case unknown
   case PENDING
   case CONFIRMED
}

public enum PositionSide {
    case unknown
    case LONG
    case SHORT
}

public enum PortfolioSection: String {
    case positions
    case orders
    case trades
    case funding
    case fees
    case transfers
}
