//
//  ERC20ApprovalStep.swift
//  dydxStateManager
//
//  Created by Rui Huang on 9/20/23.
//

import Utilities
import Combine
import Abacus
import Cartera
import BigInt
import Web3
import dydxCartera

struct ERC20ApprovalStep: AsyncStep {
    typealias ProgressType = Void
    typealias ResultType = Bool

    let chainRpc: String
    let tokenAddress: String
    let ethereumAddress: String
    let spenderAddress: String
    let provider: CarteraProvider
    let walletId: String?
    let chainIdInt: Int
    let amount: BigUInt

    private let ethereumInteractor: EthereumInteractor

    init(chainRpc: String, tokenAddress: String, ethereumAddress: String, spenderAddress: String, provider: CarteraProvider, walletId: String?, chainIdInt: Int, amount: BigUInt) {
        self.chainRpc = chainRpc
        self.tokenAddress = tokenAddress
        self.ethereumAddress = ethereumAddress
        self.spenderAddress = spenderAddress
        self.provider = provider
        self.walletId = walletId
        self.chainIdInt = chainIdInt
        self.amount = amount
        self.ethereumInteractor = EthereumInteractor(url: chainRpc)
    }

    func run() -> AnyPublisher<AsyncEvent<ProgressType, ResultType>, Never> {
        guard let contract = try? EthereumAddress(hex: tokenAddress, eip55: false),
              let from = try? EthereumAddress(hex: ethereumAddress, eip55: false),
              let spender = try? EthereumAddress(hex: spenderAddress, eip55: false) else {
            return Just(AsyncEvent.result(false, nil)).eraseToAnyPublisher()
        }
        let function = ERC20ApproveFunction(contract: contract,
                                            from: from,
                                            spender: spender,
                                            amount: amount)
        guard let transaction = try? function.transaction() else {
            return Just(AsyncEvent.result(false, nil)).eraseToAnyPublisher()
        }

        let ethereumTransactionRequest = EthereumTransactionRequest(transaction: transaction)

        return WalletSendTransactionStep(transaction: ethereumTransactionRequest,
                                         chainIdInt: chainIdInt,
                                         provider: provider,
                                         walletAddress: ethereumAddress,
                                         walletId: walletId)
        .run()
        .flatMap { event -> AnyPublisher<AsyncEvent<Void, Bool>, Never> in
            if case .result(let value, let error) = event {
                if let amount = Parser.standard.asUInt256(value), amount > BigInt.zero {
                    return Just(AsyncEvent.result(true, nil)).eraseToAnyPublisher()
                } else {
                    return Just(AsyncEvent.result(false, error)).eraseToAnyPublisher()
                }
            }

            let error = NSError(domain: "", code: -1, userInfo: [ NSLocalizedDescriptionKey: "Invalid sendTransaction"])
            return Just(AsyncEvent.result(nil, error)).eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }
}
