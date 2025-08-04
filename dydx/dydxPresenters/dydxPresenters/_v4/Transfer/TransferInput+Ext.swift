//
//  TransferInput+Ext.swift
//  dydxPresenters
//
//  Created by Rui Huang on 28/02/2025.
//

import Abacus
import dydxFormatter
import BigInt

extension TransferInput {
    var tokenAddress: String? {
        token
    }

    var tokenDecimals: Int? {
        let goFastToken = TransferTokenDetails.shared?.currentInfos.first {
            $0.tokenAddress == token && $0.chainId == chain
        }
        if let goFastToken {
            return goFastToken.decimals
        }

        if let token = token, let decimals = resources?.tokenResources?[token]?.decimals?.intValue {
            return decimals
        }
        return nil
    }

    var tokenSize: BigUInt? {
        if let size = parser.asDecimal(size?.size)?.decimalValue,
           let decimals = tokenDecimals {
            let intSize = NSDecimalNumber(decimal: size * pow(10, decimals)).uint64Value
            return BigUInt(integerLiteral: intSize)
        } else {
            return nil
        }
    }

    var chainRpc: String? {
        if let chain = chain {
            return resources?.chainResources?[chain]?.rpc
        }
        return nil
    }
}
