//
//  web3.swift
//  Copyright © 2022 Argent Labs Limited. All rights reserved.
//

import BigInt
import Foundation
import Web3

public protocol ABIFunction: ABIFunctionEncodable {
    var gasPrice: BigUInt? { get }
    var gasLimit: BigUInt? { get }
    var contract: EthereumAddress { get }
    var from: EthereumAddress? { get }
}

public protocol ABIResponse: ABITupleDecodable {}

extension ABIFunction {
    public func transaction(
        value: BigUInt? = nil,
        gasPrice: BigUInt? = nil,
        gasLimit: BigUInt? = nil
    ) throws -> EthereumTransaction {
        let encoder = ABIFunctionEncoder(Self.name)
        try encode(to: encoder)
        let data = try encoder.encoded()

        let valueQuantity: EthereumQuantity?
        if let value {
            valueQuantity = EthereumQuantity(quantity: value)
        } else {
            valueQuantity = nil
        }

        let gasPriceQuantity: EthereumQuantity?
        if let gasPrice {
            gasPriceQuantity = EthereumQuantity(quantity: gasPrice)
        } else {
            gasPriceQuantity = nil
        }

        let gasLimitQuantity: EthereumQuantity?
        if let gasLimit {
            gasLimitQuantity = EthereumQuantity(quantity: gasLimit)
        } else {
            gasLimitQuantity = nil
        }

        return EthereumTransaction(
            gasPrice: gasPriceQuantity,
            gas: gasLimitQuantity,
            from: from,
            to: contract,
            value: valueQuantity,
            data: try EthereumData(data)
        )
    }

    public func call(
        value: BigUInt? = nil,
        gasPrice: BigUInt? = nil,
        gasLimit: BigUInt? = nil
    ) throws -> EthereumCall {
        let encoder = ABIFunctionEncoder(Self.name)
        try encode(to: encoder)
        let data = try encoder.encoded()

        let valueQuantity: EthereumQuantity?
        if let value {
            valueQuantity = EthereumQuantity(quantity: value)
        } else {
            valueQuantity = nil
        }

        let gasPriceQuantity: EthereumQuantity?
        if let gasPrice {
            gasPriceQuantity = EthereumQuantity(quantity: gasPrice)
        } else {
            gasPriceQuantity = nil
        }

        let gasLimitQuantity: EthereumQuantity?
        if let gasLimit {
            gasLimitQuantity = EthereumQuantity(quantity: gasLimit)
        } else {
            gasLimitQuantity = nil
        }

        return EthereumCall(
            from: from,
            to: contract,
            gas: gasLimitQuantity,
            gasPrice: gasPriceQuantity,
            value: valueQuantity,
            data: try EthereumData(data)
        )
    }
}
