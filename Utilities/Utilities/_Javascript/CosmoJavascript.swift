//
//  CosmoJavascript.swift
//  dydxModels
//
//  Created by John Huang on 11/30/22.
//  Copyright © 2022 dYdX Trading Inc. All rights reserved.
//

import JavaScriptCore

public final class CosmoJavascript: NSObject, SingletonProtocol {
    public static var shared: CosmoJavascript = CosmoJavascript()

    private var v4ClientInitialized: Bool = false
    public var v4ClientRunner: JavascriptRunner? = {
        JavascriptRunner.runner(file: "v4-native-client.js")
    }()

    public func loadV4Client(completion: @escaping JavascriptCompletion) {
        if v4ClientInitialized {
            completion(nil)
        } else {
            if let runner = v4ClientRunner {
                runner.load { [weak self] successful in
                    self?.v4ClientInitialized = successful
                    completion(true)
                }
            } else {
                completion(nil)
            }
        }
    }

    public func deriveCosmosKey(
        signature: String,
        completion: @escaping JavascriptCompletion) {
        callNativeClient(functionName: "deriveMnemomicFromEthereumSignature", params: [signature], completion: completion)
    }

    public func getAccountBalance(completion: @escaping JavascriptCompletion) {
        callNativeClient(functionName: "getAccountBalance", params: [], completion: completion)
    }

    public func withdrawToIBC(subaccount: Int,
                              amount: String,
                              payload: String,
                              completion: @escaping JavascriptCompletion) {
        if let data = payload.data(using: .utf8) {
            let base64String = data.base64EncodedString()
            callNativeClient(functionName: "withdrawToIBC", params: [subaccount, amount, base64String], completion: completion)
        } else {
            assertionFailure("Invalid data")
        }
    }

    public func depositToSubaccount(subaccount: Int,
                                    amount: String,
                                    completion: @escaping JavascriptCompletion) {
        let json = "{\"subaccountNumber\": \(subaccount),\"amount\": \"\(amount)\"}"
        callNativeClient(functionName: "deposit", params: [json], completion: completion)
    }

    public func withdrawFromSubaccount(subaccount: Int,
                                    amount: String,
                                    completion: @escaping JavascriptCompletion) {
        let json = "{\"subaccountNumber\": \(subaccount),\"amount\": \"\(amount)\"}"
        callNativeClient(functionName: "withdraw", params: [json], completion: completion)
    }

    private func callNativeClient(functionName: String, params: [Any?], completion: @escaping JavascriptCompletion) {
        loadV4Client { [weak self] _ in
            DispatchQueue.main.async {
                if let runner = self?.v4ClientRunner {
                    runner.invoke(className: nil, function: functionName, params: params) { result in
                        DispatchQueue.main.async {
                            completion(result)
                        }
                    }
                } else {
                    completion(nil)
                }
            }
        }
    }

    public func getWithdrawalCapacityByDenom(denom: String, completion: @escaping JavascriptCompletion) {
        callNativeClient(functionName: "getWithdrawalCapacityByDenom", params: [denom]) { result in
            completion(result)
        }
    }

    public func getWithdrawalAndTransferGatingStatus(completion: @escaping JavascriptCompletion) {
        callNativeClient(functionName: "getWithdrawalAndTransferGatingStatus", params: []) { result in
            completion(result)
        }
    }

    public func test(completion: @escaping JavascriptCompletion) {
        callNativeClient(functionName: "connectClient", params: ["dydxprotocol-staging"]) { result in
            self.callNativeClient(functionName: "getPerpetualMarkets", params: []) { result in
                completion(result)
            }
        }
    }

    public func connectNetwork(paramsInJson: String, completion: @escaping JavascriptCompletion) {
        callNativeClient(functionName: "connectNetwork", params: [paramsInJson]) { result in
            completion(result)
        }
    }

    public func connectWallet(mnemonic: String, completion: @escaping JavascriptCompletion) {
        callNativeClient(functionName: "connectWallet", params: [mnemonic]) { result in
            completion(result)
        }
    }
    
    public func getMegavaulOwnerShares(payload: String) async -> String? {
        return await call(functionName: "getMegavaultOwnerShares", params: [payload])
    }
    
    public func getMegavaultWithdrawalInfo(sharesToWithdraw: Double) async -> String? {
        return await call(functionName: "getMegavaultWithdrawalInfo", params: [sharesToWithdraw])
    }

    public func depositToMegavault(subaccountNumber: Int32, amountUsdc: Double) async -> Result<ChainSuccessResponse, ChainError> {
        let response = await call(functionName: "depositToMegavault", params: [subaccountNumber, amountUsdc])
        return handleChainResponse(response)
    }

    public func withdrawFromMegavault(subaccountTo: String, shares: Double, minAmount: Double) async -> Result<ChainSuccessResponse, ChainError> {
        let response = await call(functionName: "withdrawFromMegavault", params: [subaccountTo, shares, minAmount])
        return handleChainResponse(response)
    }
    
    // Helper function for parsing the response
    private func handleChainResponse(_ response: String?) -> Result<ChainSuccessResponse, ChainError> {
        guard let response = response else {
            return .failure(.unknownError)
        }
        
        guard let jsonData = response.data(using: .utf8) else {
            return .failure(.unknownError)
        }
        
        do {
            // Try to decode the error first
            if let error = try? JSONDecoder().decode(ChainErrorResponse.self, from: jsonData) {
                return .failure(error.error)
            }
            
            // If no error, decode the success response
            let success = try JSONDecoder().decode(ChainSuccessResponse.self, from: jsonData)
            return .success(success)
        } catch {
            return .failure(.unknownError)
        }
    }
    
    public func call(functionName: String, params: [Any?]) async -> String? {
        return await withCheckedContinuation { continuation in
            self.callNativeClient(functionName: functionName, params: params) { result in
                continuation.resume(returning: result as? String)
            }
        }
    }

    public func getMegavaulOwnerShares(payload: String) async -> String? {
        return await call(functionName: "getMegavaultOwnerShares", params: [payload])
    }

    public func getMegavaultWithdrawalInfo(sharesToWithdraw: Double) async -> String? {
        return await call(functionName: "getMegavaultWithdrawalInfo", params: [sharesToWithdraw])
    }

    public func depositToMegavault(subaccountNumber: Int32, amountUsdc: Double) async -> Result<ChainSuccessResponse, ChainError> {
        let response = await call(functionName: "depositToMegavault", params: [subaccountNumber, amountUsdc])
        return handleChainResponse(response)
    }

    public func withdrawFromMegavault(subaccountTo: String, shares: Double, minAmount: Double) async -> Result<ChainSuccessResponse, ChainError> {
        let response = await call(functionName: "withdrawFromMegavault", params: [subaccountTo, shares, minAmount])
        return handleChainResponse(response)
    }

    public func call(functionName: String, params: [Any?]) async -> String? {
        return await withCheckedContinuation { continuation in
            self.callNativeClient(functionName: functionName, params: params) { result in
                continuation.resume(returning: result as? String)
            }
        }
    }

    public func call(functionName: String, paramsInJson: String?, completion: @escaping JavascriptCompletion) {
        callNativeClient(functionName: functionName, params: paramsInJson != nil ? [paramsInJson!] : []) { result in
            completion(result)
        }
    }

    // Helper function for parsing the response
    private func handleChainResponse(_ response: String?) -> Result<ChainSuccessResponse, ChainError> {
        guard let response = response else {
            return .failure(.unknownError)
        }

        guard let jsonData = response.data(using: .utf8) else {
            return .failure(.unknownError)
        }

        do {
            // Try to decode the error first
            if let error = try? JSONDecoder().decode(ChainErrorResponse.self, from: jsonData) {
                return .failure(error.error)
            }

            // If no error, decode the success response
            let success = try JSONDecoder().decode(ChainSuccessResponse.self, from: jsonData)
            return .success(success)
        } catch {
            return .failure(.unknownError)
        }
    }
}

//TODO: Replace?
// Define the structure of the error message
public struct ChainError: Decodable, Error {
    static let unknownError = ChainError(message: "An unknown error occurred", line: nil, column: nil, stack: nil)

    public let message: String
    public let line: Int?
    public let column: Int?
    public let stack: String?
}

public struct ChainErrorResponse: Decodable, Error {
    public let error: ChainError
}

// Define the structure of the success message
public struct ChainEvent: Decodable {
    let type: String
    let attributes: [ChainEventAttribute]
}

public struct ChainEventAttribute: Decodable {
    let key: String
    let value: String
}

public struct ChainSuccessResponse: Decodable {
    let height: Int?
    let hash: String?
    let code: Int?
    let tx: String
    let txIndex: Int?
    let gasUsed: String?
    let gasWanted: String?
    let events: [ChainEvent]?
}

/* to test
 Add this code somewhere
 CosmoJavascript.shared.test { result in
     Console.shared.log(result)
 }
 */
