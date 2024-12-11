//
//  Parser+Eth.swift
//  dydxCartera
//
//  Created by John Huang on 3/17/22.
//  Copyright © 2022 dYdX Trading Inc. All rights reserved.
//

import BigInt
import Utilities

public extension Parser {
    func asInt256(_ data: Any?) -> BigInt? {
        if var string = data as? String {
            if string.starts(with: "0x") {
                string = string.replacingOccurrences(of: "0x", with: "")
            }
            return BigInt(string, radix: 16)
        }
        return nil
    }

    func asUInt256(_ data: Any?) -> BigUInt? {
        if var string = data as? String {
            if string.starts(with: "0x") {
                string = string.replacingOccurrences(of: "0x", with: "")
            }
            return BigUInt(string, radix: 16)
        } else if let bigint = data as? BigInt {
            return BigUInt(bigint)
        } else if let biguint = data as? BigUInt {
            return biguint
        } else if let int = self.asInt(data) {
            return BigUInt(int)
        }
        return nil
    }
}
