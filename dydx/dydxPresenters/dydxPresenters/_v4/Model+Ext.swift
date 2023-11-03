//
//  Model+Ext.swift
//  dydxPresenters
//
//  Created by Rui Huang on 5/11/23.
//

import Foundation
import Abacus
import dydxViews

extension OrderStatusModel {

    convenience init(order: Abacus.SubaccountOrder) {
        switch order.status {
        case .cancelled, .canceling:
            self.init(status: .red)
        case .filled:
            self.init(status: .green)
        case .partiallyfilled, .pending:
            self.init(status: .yellow)
        case .open, .untriggered, .cancelled:
            self.init(status: .blank)
        default:
            self.init(status: .blank)
        }
    }
}

extension OrderStatus {
    var canCancel: Bool {
        switch self {
        case .open, .pending, .partiallyfilled, .untriggered: return true
        default: return false
        }
    }
}
