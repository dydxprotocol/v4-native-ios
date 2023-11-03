//
//  ERC20AllowanceStep.swift
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

struct ERC20AllowanceStep: AsyncStep {
    typealias ProgressType = Void
    typealias ResultType = BigUInt

    let tokenAddress: String
    let ethereumAddress: String
    let spenderAddress: String

    private let ethereumInteractor: EthereumInteractor

    init(chainRpc: String, tokenAddress: String, ethereumAddress: String, spenderAddress: String) {
        self.tokenAddress = tokenAddress
        self.ethereumAddress = ethereumAddress
        self.spenderAddress = spenderAddress
        self.ethereumInteractor = EthereumInteractor(url: chainRpc)
    }

    func run() -> AnyPublisher<Utilities.AsyncEvent<ProgressType, ResultType>, Never> {
        return AnyPublisher<AsyncEvent<Void, ResultType>, Never>.create { subscriber in

            let function = ERC20AllowanceFunction(contract: EthereumAddress(tokenAddress),
                                                  from: EthereumAddress(ethereumAddress),
                                                  owner: EthereumAddress(ethereumAddress),
                                                  spender: EthereumAddress(spenderAddress))

            if let transaction = try? function.transaction() {
                ethereumInteractor.eth_call(transaction) { error, value in
                    let amount = Parser.standard.asUInt256(value)
                    if let amount = amount {
                        _ = subscriber.receive(.result(amount, nil))
                    } else {
                        _ = subscriber.receive(.result(nil, error))
                    }
                }
            } else {
                let error = NSError(domain: "", code: -1, userInfo: [ NSLocalizedDescriptionKey: "Invalid Input"])
                _ = subscriber.receive(.result(nil, error))
            }

            return AnyCancellable {
                // Imperative cancellation implementation
            }
        }
        .eraseToAnyPublisher()
    }
}
