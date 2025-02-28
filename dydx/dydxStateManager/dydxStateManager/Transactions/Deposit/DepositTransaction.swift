//
//  DepositTransaction.swift
//  dydxStateManager
//
//  Created by Rui Huang on 4/18/23.
//

import Foundation
import Utilities
import Combine
import Abacus
import Cartera
import dydxFormatter
import BigInt

public struct DepositTransaction: AsyncStep {
    public typealias ProgressType = Void
    public typealias ResultType = String        // Returning transaction hash

    private let depositTransactionV4: DepositTransactionV4?

    public let walletAddress: String?
    public let walletId: String?
    public let tokenAddress: String?
    public let chainRpc: String?
    public let payload: TransferInputRequestPayload?
    public let tokenSize: BigUInt?
    public let chainId: String?

    public init(walletAddress: String?,
                walletId: String?,
                tokenAddress: String?,
                chainRpc: String?,
                payload: TransferInputRequestPayload?,
                tokenSize: BigUInt?,
                chainId: String?) {
       self.walletAddress = walletAddress
        self.walletId = walletId
        self.tokenAddress = tokenAddress
        self.chainRpc = chainRpc
        self.payload = payload
        self.tokenSize = tokenSize
        self.chainId = chainId

        if let walletAddress = walletAddress,
           let chainId = chainId,
           let chainRpc = chainRpc,
           let tokenAddress = tokenAddress {
            depositTransactionV4 = DepositTransactionV4(payload: payload,
                                                        tokenSize: tokenSize,
                                                        chainId: chainId,
                                                        provider: CarteraProvider(),
                                                        walletAddress: walletAddress,
                                                        walletId: walletId,
                                                        chainRpc: chainRpc,
                                                        tokenAddress: tokenAddress)
        } else {
            depositTransactionV4 = nil
        }
    }

    public func run() -> AnyPublisher<AsyncEvent<ProgressType, ResultType>, Never> {
        depositTransactionV4?.run() ?? Empty<AsyncEvent<Void, ResultType>, Never>().eraseToAnyPublisher()
    }
}
