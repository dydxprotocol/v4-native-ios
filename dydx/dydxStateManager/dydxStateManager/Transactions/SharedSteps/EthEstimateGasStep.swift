//
//  EthEstimateGasStep.swift
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

struct EthEstimateGasStep: AsyncStep {
    typealias ProgressType = Void
    typealias ResultType = BigUInt

    let transaction: EthereumTransaction

    private let ethereumInteractor: EthereumInteractor

    init(chainRpc: String, transaction: EthereumTransaction) {
        self.transaction = transaction
        self.ethereumInteractor = EthereumInteractor(url: chainRpc)
    }

    func run() -> AnyPublisher<Utilities.AsyncEvent<ProgressType, ResultType>, Never> {
        return AnyPublisher<AsyncEvent<Void, ResultType>, Never>.create { subscriber in
            ethereumInteractor.eth_estimateGas(transaction) { error, value in
                if let value = value {
                    _ = subscriber.receive(.result(value * 11 / 10, error))
                } else if let error = error {
                    _ = subscriber.receive(.result(nil, error))
                }
            }

            return AnyCancellable {
                // Imperative cancellation implementation
            }
        }
        .eraseToAnyPublisher()
    }
}
