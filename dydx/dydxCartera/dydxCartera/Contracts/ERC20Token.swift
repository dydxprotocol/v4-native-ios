//
//  ERC20Token.swift
//  dydxModels
//
//  Created by John Huang on 1/6/22.
//  Copyright © 2022 dYdX Trading Inc. All rights reserved.
//

import BigInt
import Web3

public struct ERC20AllowanceFunction: ContractFunction {
    public init(contract: EthereumAddress, from: EthereumAddress? = nil, owner: EthereumAddress, spender: EthereumAddress) {
        self.contract = contract
        self.from = from
        self.owner = owner
        self.spender = spender
    }

    public static let name = "allowance"
    public let gasPrice: BigUInt? = nil
    public let gasLimit: BigUInt? = nil
    public let contract: EthereumAddress
    public let from: EthereumAddress?

    public let owner: EthereumAddress
    public let spender: EthereumAddress

    public func data() -> [Any] {
        return [owner, spender]
    }
}

public struct ERC20ApproveFunction: ContractFunction {
    public init(contract: EthereumAddress, from: EthereumAddress? = nil, spender: EthereumAddress, amount: BigUInt = BigUInt("ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff", radix: 16)!) {
        self.contract = contract
        self.from = from
        self.spender = spender
        self.amount = amount
    }

    public static let name = "approve"
    public let gasPrice: BigUInt? = nil
    public let gasLimit: BigUInt? = nil
    public let contract: EthereumAddress
    public let from: EthereumAddress?

    public let spender: EthereumAddress

    public let amount: BigUInt

    public func data() -> [Any] {
        return [spender, amount]
    }
}

public struct ERC20BalanceOfFunction: ContractFunction {
    public static let name = "balanceOf"
    public let gasPrice: BigUInt? = nil
    public let gasLimit: BigUInt? = nil
    public let contract: EthereumAddress
    public let from: EthereumAddress?

    public let account: EthereumAddress

    public func data() -> [Any] {
        return [account]
    }

    public init(contract: EthereumAddress, from: EthereumAddress? = nil, account: EthereumAddress) {
        self.contract = contract
        self.from = from
        self.account = account
    }
}
