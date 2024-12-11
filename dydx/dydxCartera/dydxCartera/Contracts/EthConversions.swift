//
//  EthConversions.swift
//  dydxModels
//
//  Created by Qiang Huang on 5/13/21.
//  Copyright © 2021 dYdX. All rights reserved.
//

import BigInt
import Utilities
import Web3

public class EthConversions {
    static let BASE_DECIMALS = 6
    static let ETH_DECIMALS = 18

    public static func starkKeyToUint256(starkKey: String) -> String? {
        if let number = BigUInt(starkKey, radix: 16) {
            return String(number)
        }
        return nil
    }

    public static func bignumber(amount: Any) -> BigUInt? {
        if let bignumber = amount as? BigUInt {
            return bignumber
        } else if let bignumber = amount as? BigInt {
            return BigUInt(bignumber)
        } else if let number = Parser().asInt(amount) {
            return BigUInt(number)
        } else {
            return nil
        }
    }

    public static func bignumberableToUint256(amount: Any) -> String? {
        if let bignumber = amount as? BigUInt {
            return String(bignumber)
        } else if let bignumber = amount as? BigInt {
            return String(bignumber)
        } else if let number = Parser().asInt(amount) {
            return String(number)
        } else {
            return nil
        }
    }

    public static func humanTokenAmountToUint256(humanAmount: Decimal, decimals: Int) -> BigUInt? {
        let shifted = humanAmount * Decimal(pow(10, Double(decimals)))
        let number = NSDecimalNumber(decimal: shifted)
        return BigUInt(number.doubleValue)
    }

    public static func humanCollateralAmountToUint256(humanAmount: Decimal) -> BigUInt? {
        return humanTokenAmountToUint256(humanAmount: humanAmount, decimals: BASE_DECIMALS)
    }

    public static func humanEthAmountToUint256(humanAmount: Decimal) -> BigUInt? {
        return humanTokenAmountToUint256(humanAmount: humanAmount, decimals: ETH_DECIMALS)
    }

    // From-Contract Helpers

    public static func uint256ToHumanTokenAmount(output: String, decimals: Int) -> Double? {
        if let number = Double(output) {
            return number / pow(10, Double(decimals))
        }
        return nil
    }

    public static func uint256ToHumanEthAmount(output: String) -> Double? {
        return uint256ToHumanTokenAmount(output: output, decimals: ETH_DECIMALS)
    }

    public static func uint256ToHumanCollateralTokenAmount(output: String) -> Double? {
        return uint256ToHumanTokenAmount(output: output, decimals: BASE_DECIMALS)
    }

    public static func uint256ToHumanTokenString(output: String, decimals: Int) -> String? {
        // work on string directly
        let length = output.length
        if length == decimals {
            return "0.\(output)".removeTrailing("0")
        } else if length > decimals {
            let beforeDecimal = output.substring(toIndex: length - decimals)
            let afterDecimal = output.substring(fromIndex: length - decimals)
            return "\(beforeDecimal).\(afterDecimal)".removeTrailing("0")
        } else {
            let afterDecimal = output.prefix("0", length: decimals)
            return "0.\(afterDecimal)".removeTrailing("0")
        }
    }

    public static func uint256ToHumanEthString(output: String) -> String? {
        return uint256ToHumanTokenString(output: output, decimals: ETH_DECIMALS)
    }

    public static func uint256ToHumanCollateralTokenString(output: String) -> String? {
        return uint256ToHumanTokenString(output: output, decimals: BASE_DECIMALS)
    }
}
