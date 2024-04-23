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
            let result = result as? String
            Console.shared.log("AbacusChainImp.connectNetwork \(paramsInJson), result: \(result ?? "nil")")
            callback(result)
        }
    }

    public func transaction(type: TransactionType, paramsInJson: String?, callback: @escaping (String?) -> Void) {
        CosmoJavascript.shared.call(functionName: type.rawValue, paramsInJson: paramsInJson) { result in
            let result = result as? String
            Console.shared.log("AbacusChainImp.transaction \(type.rawValue), param \(paramsInJson ?? "nil"), result: \(result ?? "nil")")
            callback(result)
        }
    }

    public func get(type: QueryType, paramsInJson: String?, callback: @escaping (String?) -> Void) {
        CosmoJavascript.shared.call(functionName: type.rawValue, paramsInJson: paramsInJson) { result in
            let result = result as? String
            Console.shared.log("AbacusChainImp.get \(type.rawValue), param \(paramsInJson ?? "nil"), result: \(result ?? "nil")")
            callback(result)
        }
    }

}
