//
//  EthGetNonceStep.swift
//  dydxStateManager
//
//  Created by Rui Huang on 10/8/23.
//

import Utilities
import Combine
import Cartera
import BigInt
import web3
import dydxCartera

struct EthGetNonceStep: AsyncStep {
    typealias ProgressType = Void
    typealias ResultType = Int

    let address: EthereumAddress

    private let ethereumInteractor: EthereumInteractor

    init(chainRpc: String, address: EthereumAddress) {
        self.address = address
        self.ethereumInteractor = EthereumInteractor(url: chainRpc)
    }

    func run() -> AnyPublisher<Utilities.AsyncEvent<ProgressType, ResultType>, Never> {
        return AnyPublisher<AsyncEvent<Void, ResultType>, Never>.create { subscriber in
            ethereumInteractor.eth_getTransactionCount(address: address, block: .Pending) { error, value in
                if let value = value {
                    _ = subscriber.receive(.result(value, error))
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
