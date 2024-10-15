//
//  VaultNetworking.swift
//  dydxPresenters
//
//  Created by Michael Maguire on 10/15/24.
//

import Utilities
import Abacus

extension CosmoJavascript {
    public func depositToMegavault(subaccountNumber: Int32, amountUsdc: Double) async -> Result<Abacus.OnChainTransactionSuccessResponse, ChainError> {
        let response = await call(functionName: "depositToMegavault", params: [subaccountNumber, amountUsdc])
        return handleChainResponse(response)
    }

    public func withdrawFromMegavault(subaccountTo: String, shares: Double, minAmount: Double) async -> Result<Abacus.OnChainTransactionSuccessResponse, ChainError> {
        let response = await call(functionName: "withdrawFromMegavault", params: [subaccountTo, shares, minAmount])
        return handleChainResponse(response)
    }

    public func getMegavaulOwnerShares(payload: String) async -> String? {
        return await call(functionName: "getMegavaultOwnerShares", params: [payload])
    }

    public func getMegavaultWithdrawalInfo(sharesToWithdraw: Double) async -> String? {
        return await call(functionName: "getMegavaultWithdrawalInfo", params: [sharesToWithdraw])
    }

    private func call(functionName: String, params: [Any?]) async -> String? {
        return await withCheckedContinuation { continuation in
            self.callNativeClient(functionName: functionName, params: params) { result in
                continuation.resume(returning: result as? String)
            }
        }
    }

    // Helper function for parsing the response
    private func handleChainResponse(_ response: String?) -> Result<Abacus.OnChainTransactionSuccessResponse, ChainError> {
        guard let response = response else {
            return .failure(.companion.unknownError)
        }
        if let parsedSuccessResponse = Abacus.OnChainTransactionSuccessResponse.companion.fromPayload(payload: response) {
            return .success(parsedSuccessResponse)
        } else {
            return .failure(.companion.unknownError)
        }
    }
}

extension ChainError: @retroactive Error {}
