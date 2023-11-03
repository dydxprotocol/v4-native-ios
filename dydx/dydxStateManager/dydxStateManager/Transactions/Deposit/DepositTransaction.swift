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

public struct DepositTransaction: AsyncStep {
    public typealias ProgressType = Void
    public typealias ResultType = String        // Returning transaction hash

    private let depositTransactionV4: DepositTransactionV4?

    public let transferInput: TransferInput
    public let walletAddress: String?
    public let walletId: String?

    public init(transferInput: TransferInput, walletAddress: String?, walletId: String?) {
        self.transferInput = transferInput
        self.walletAddress = walletAddress
        self.walletId = walletId

        if let walletAddress = walletAddress,
            let chain = transferInput.chain, let token = transferInput.token,
           let chainRpc = transferInput.resources?.chainResources?[chain]?.rpc,
           let tokenAddress = transferInput.resources?.tokenResources?[token]?.address {
            depositTransactionV4 = DepositTransactionV4(transferInput: transferInput,
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
