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
import Web3
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

            if let call =
                try? ERC20AllowanceFunction(contract: EthereumAddress(hex: tokenAddress, eip55: false),
                                            from: EthereumAddress(hex: ethereumAddress, eip55: false),
                                            owner: EthereumAddress(hex: ethereumAddress, eip55: false),
                                            spender: EthereumAddress(hex: spenderAddress, eip55: false)).call() {
                ethereumInteractor.eth_call(call) { result in
                    switch result.status {
                    case .success(let value):
                        let amount = Parser.standard.asUInt256(value.ethereumValue().string)
                        if let amount = amount {
                            _ = subscriber.receive(.result(amount, nil))
                        } else {
                            _ = subscriber.receive(.result(nil, result.error))
                        }
                    case .failure(let error):
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
