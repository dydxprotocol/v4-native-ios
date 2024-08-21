//
//  EthGetGasPriceStep.swift
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

struct EthGetGasPriceStep: AsyncStep {
    typealias ProgressType = Void
    typealias ResultType = BigUInt

    private let ethereumInteractor: EthereumInteractor

    init(chainRpc: String) {
        self.ethereumInteractor = EthereumInteractor(url: chainRpc)
    }

    func run() -> AnyPublisher<Utilities.AsyncEvent<ProgressType, ResultType>, Never> {
        return AnyPublisher<AsyncEvent<Void, ResultType>, Never>.create { subscriber in
            ethereumInteractor.eth_gasPrice { error, gasPrice in
                if let gasPrice = gasPrice {
                    _ = subscriber.receive(.result(gasPrice, error))
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
