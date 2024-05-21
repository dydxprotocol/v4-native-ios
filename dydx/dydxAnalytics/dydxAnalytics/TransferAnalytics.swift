//
//  TransferAnalytics.swift
//  dydxPresenters
//
//  Created by Rui Huang on 26/03/2024.
//

import Foundation
import Abacus
import Utilities

public final class TransferAnalytics {

    public init() {}

    public func logDeposit(transferInput: TransferInput) {
        log(event: .transferDeposit, transferInput: transferInput)
    }

    public func logWithdrawal(transferInput: TransferInput) {
        log(event: .transferWithdraw, transferInput: transferInput)
    }

    private func log(event: AnalyticsEvent, transferInput: TransferInput) {
        let data = [
            "chainId": Parser.standard.asString(transferInput.chainResource?.chainId),
            "tokenAddress": transferInput.tokenResource?.address,
            "tokenSymbol": transferInput.tokenResource?.symbol,
            "slippage": Parser.standard.asString(transferInput.summary?.slippage),
            "gasFee": Parser.standard.asString(transferInput.summary?.gasFee),
            "bridgeFee": Parser.standard.asString(transferInput.summary?.bridgeFee),
            "exchangeRate": Parser.standard.asString(transferInput.summary?.exchangeRate),
            "estimatedRouteDuration": Parser.standard.asString(transferInput.summary?.estimatedRouteDuration),
            "toAmount": Parser.standard.asString(transferInput.summary?.toAmount),
            "toAmountMin": Parser.standard.asString(transferInput.summary?.toAmountMin)
        ].filterNils() as? [String: String]

        Tracking.shared?.log(event: event.rawValue,
                             data: data)
    }
}

private extension TransferInput {
    var chainResource: TransferInputChainResource? {
        if let chain = chain {
            return resources?.chainResources?[chain]
        }
        return nil
    }

    var tokenResource: TransferInputTokenResource? {
        if let token = token {
            return resources?.tokenResources?[token]
        }
        return nil
    }
}
