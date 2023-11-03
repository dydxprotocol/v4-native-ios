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
import web3
import dydxCartera

struct ERC20ApprovalStep: AsyncStep {
    typealias ProgressType = Void
    typealias ResultType = Bool

    let chainRpc: String
    let tokenAddress: String
    let ethereumAddress: String
    let spenderAddress: String
    let provider: CarteraProvider
    let walletId: String
    let chainIdInt: Int
    let amount: BigUInt

    private let ethereumInteractor: EthereumInteractor

    init(chainRpc: String, tokenAddress: String, ethereumAddress: String, spenderAddress: String, provider: CarteraProvider, walletId: String, chainIdInt: Int, amount: BigUInt) {
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
        let function = ERC20ApproveFunction(gasPrice: nil,
                                            gasLimit: nil,
                                            contract: EthereumAddress(tokenAddress),
                                            from: EthereumAddress(ethereumAddress),
                                            spender: EthereumAddress(spenderAddress),
                                            amount: amount)
        guard let transaction = try? function.transaction() else {
            return Just(AsyncEvent.result(false, nil)).eraseToAnyPublisher()
        }

        // Run in parallel 
        return Publishers.Zip3(
            EthGetGasPriceStep(chainRpc: chainRpc).run(),
            EthEstimateGasStep(chainRpc: chainRpc, transaction: transaction).run(),
            EthGetNonceStep(chainRpc: chainRpc, address: EthereumAddress(ethereumAddress)).run()
        )
        .flatMap { (gasPriceEvent, estimateGasEvent, nonceEvent) -> AnyPublisher<AsyncEvent<Void, String>, Never> in
            if case .result(let gasPrice, let gasPriceError) = gasPriceEvent,
               case .result(let gas, let gasError) = estimateGasEvent,
               case .result(let nonce, let nonceError) = nonceEvent {
                if let gasPrice = gasPrice, let gas = gas, let nonce = nonce {
                    let ethereumTransactionRequest = EthereumTransactionRequest(transaction: transaction, gasPrice: gasPrice, gas: gas, nonce: nonce)

                    return WalletSendTransactionStep(transaction: ethereumTransactionRequest,
                                                     chainIdInt: chainIdInt,
                                                     provider: provider,
                                                     walletAddress: ethereumAddress,
                                                     walletId: walletId)
                        .run()
                } else {
                    if let gasPriceError = gasPriceError {
                        return Just(AsyncEvent.result(nil, gasPriceError)).eraseToAnyPublisher()
                    } else if let gasError = gasError {
                        return Just(AsyncEvent.result(nil, gasError)).eraseToAnyPublisher()
                    } else if let nonceError = nonceError {
                        return Just(AsyncEvent.result(nil, nonceError)).eraseToAnyPublisher()
                    }
                }
            }
            let error = NSError(domain: "", code: -1, userInfo: [ NSLocalizedDescriptionKey: "Invalid gas or gasPrice"])
            return Just(AsyncEvent.result(nil, error)).eraseToAnyPublisher()
        }
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
