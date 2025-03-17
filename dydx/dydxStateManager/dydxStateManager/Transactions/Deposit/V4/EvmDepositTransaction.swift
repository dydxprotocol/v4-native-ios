//
//  DepositTransactionV4.swift
//  dydxStateManager
//
//  Created by Rui Huang on 4/18/23.
//

import Abacus
import BigInt
import Cartera
import Combine
import Foundation
import Utilities
import Web3

struct EvmDepositTransaction: AsyncStep {
    typealias ProgressType = Void
    typealias ResultType = String

    let payload: TransferInputRequestPayload?
    let tokenSize: BigUInt?
    let chainId: String?
    let provider: CarteraProvider
    let walletAddress: String
    let walletId: String?
    let chainRpc: String
    let tokenAddress: String

    func run() -> AnyPublisher<AsyncEvent<Void, ResultType>, Never> {
        guard let payload = payload,
              let targetAddress = payload.targetAddress,
              let tokenSize = tokenSize,
              let chainId = chainId,
              let chainIdInt = Parser.standard.asInt(chainId),
              let ethereumTransactionRequest = EthereumTransactionRequest(requestPayload: payload,
                                                                          chainId: chainIdInt,
                                                                          walletAddress: walletAddress) else {
            let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid input"])
            return Just(AsyncEvent.result(nil, error)).eraseToAnyPublisher()
        }

        return EnableERC20TokenStep(chainRpc: chainRpc,
                                    tokenAddress: tokenAddress,
                                    ethereumAddress: walletAddress,
                                    spenderAddress: targetAddress,
                                    desiredAmount: tokenSize,
                                    walletId: walletId,
                                    chainIdInt: chainIdInt)
            .run()
            .flatMap { event -> AnyPublisher<AsyncEvent<Void, String>, Never> in
                if case let .result(enabled, error) = event {
                    if enabled == true {
                        return WalletSendTransactionStep(transaction: ethereumTransactionRequest,
                                                         solana: nil,
                                                         chainIdInt: chainIdInt,
                                                         provider: provider,
                                                         walletAddress: walletAddress,
                                                         walletId: walletId)
                            .run()
                    } else if let error = error {
                        return Just(AsyncEvent.result(nil, error)).eraseToAnyPublisher()
                    } else {
                        let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid Nonce"])
                        return Just(AsyncEvent.result(nil, error)).eraseToAnyPublisher()
                    }
                }
                return Empty<AsyncEvent<Void, String>, Never>().eraseToAnyPublisher()
            }
            .flatMap { event -> AnyPublisher<AsyncEvent<Void, ResultType>, Never> in
                if case let .result(hash, error) = event {
                    if hash != nil {
                        return Just(AsyncEvent.result(hash, nil)).eraseToAnyPublisher()
                    } else {
                        return Just(AsyncEvent.result(nil, error)).eraseToAnyPublisher()
                    }
                }
                return Empty<AsyncEvent<Void, ResultType>, Never>().eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}

private extension TransferInput {
    var tokenSize: BigUInt? {
        if let size = parser.asDecimal(size?.size)?.decimalValue,
           let token = token, let decimal = resources?.tokenResources?[token]?.decimals?.intValue {
            let intSize = NSDecimalNumber(decimal: size * pow(10, decimal)).uint64Value
            return BigUInt(integerLiteral: intSize)
        } else {
            return nil
        }
    }
}

private extension EthereumTransactionRequest {
    init?(requestPayload: TransferInputRequestPayload, chainId: Int?, walletAddress: String) {
        guard let targetAddress = requestPayload.targetAddress,
              let payloadData = requestPayload.data,
              let data = try? EthereumData.string(payloadData),
              let from = try? EthereumAddress(hex: walletAddress, eip55: false),
              let to = try? EthereumAddress(hex: targetAddress, eip55: false) else {
            return nil
        }

        let value: EthereumQuantity?
        if let payloadValue = requestPayload.value, let bigUIntValue = payloadValue.asBigUInt {
            value = EthereumQuantity(quantity: bigUIntValue)
        } else {
            value = nil
        }

        let transaction = EthereumTransaction(from: from,
                                              to: to,
                                              value: value,
                                              data: data)

        self.init(transaction: transaction)
    }
}

private extension String {
    var asBigUInt: BigUInt? {
        BigUInt(self)
    }
}
