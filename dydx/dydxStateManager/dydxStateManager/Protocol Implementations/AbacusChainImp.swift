//
//  AbacusChainImp.swift
//  dydxStateManager
//
//  Created by John Huang on 7/17/23.
//

import Foundation
import Abacus
import Utilities

final public class AbacusChainImp: Abacus.DYDXChainTransactionsProtocol {
    public func connectNetwork(paramsInJson: String, callback: @escaping (String?) -> Void) {
        CosmoJavascript.shared.connectNetwork(paramsInJson: paramsInJson) { result in
            callback(result as? String)
        }
    }

    public func transaction(type: TransactionType, paramsInJson: String?, callback: @escaping (String?) -> Void) {
        CosmoJavascript.shared.call(functionName: type.rawValue, paramsInJson: paramsInJson) { result in
            callback(result as? String)
        }
    }

    public func get(type: QueryType, paramsInJson: String?, callback: @escaping (String?) -> Void) {
        CosmoJavascript.shared.call(functionName: type.rawValue, paramsInJson: paramsInJson) { result in
            callback(result as? String)
        }
    }

}
