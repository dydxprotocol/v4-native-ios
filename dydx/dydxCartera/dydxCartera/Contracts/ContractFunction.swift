//
//  ABIFunction+Encode.swift
//  dydxModels
//
//  Created by Qiang Huang on 7/2/21.
//  Copyright © 2021 dYdX. All rights reserved.
//

import BigInt
import Web3

public protocol ContractFunction: ABIFunction {
    func data() -> [Any]
}

public extension ContractFunction {
    func encode(to encoder: ABIFunctionEncoder) throws {
        let data = self.data()
        for item in data {
            if let piece = item as? ABIType {
                try encoder.encode(piece)
            } else if let pieces = item as? [String] {
                try encoder.encode(pieces)
            } else if let pieces = item as? [Bool] {
                try encoder.encode(pieces)
            } else if let pieces = item as? [EthereumAddress] {
                try encoder.encode(pieces)
            } else if let pieces = item as? [BigInt] {
                try encoder.encode(pieces)
            } else if let pieces = item as? [BigUInt] {
                try encoder.encode(pieces)
            } else if let pieces = item as? [UInt8] {
                try encoder.encode(pieces)
            } else if let pieces = item as? [UInt16] {
                try encoder.encode(pieces)
            } else if let pieces = item as? [UInt32] {
                try encoder.encode(pieces)
            } else if let pieces = item as? [UInt64] {
                try encoder.encode(pieces)
            } else if let pieces = item as? [URL] {
                try encoder.encode(pieces)
            } else if let pieces = item as? [Data] {
                try encoder.encode(pieces)
            } else {
            }
        }
    }
}
