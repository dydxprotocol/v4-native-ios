//
//  EnableERC20TokenStep.swift
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

struct EnableERC20TokenStep: AsyncStep {
    typealias ProgressType = Void
    typealias ResultType = Bool

    let chainRpc: String
    let tokenAddress: String
    let ethereumAddress: String
    let spenderAddress: String
    let desiredAmount: BigUInt
    let walletId: String?
    let chainIdInt: Int

    func run() -> AnyPublisher<Utilities.AsyncEvent<ProgressType, ResultType>, Never> {
        if tokenAddress == "0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE" {
            return Just(AsyncEvent.result(true, nil)).eraseToAnyPublisher()
        } else {
            return ERC20AllowanceStep(chainRpc: chainRpc,
                                      tokenAddress: tokenAddress,
                                      ethereumAddress: ethereumAddress,
                                      spenderAddress: spenderAddress)
            .run()
            .flatMap {  event -> AnyPublisher<AsyncEvent<Void, Bool>, Never> in
                if case .result(let allowance, let error) = event {
                    if let allowance = allowance {
                        if allowance >= desiredAmount {
                            return Just(AsyncEvent.result(true, nil)).eraseToAnyPublisher()
                        } else {
                            return ERC20ApprovalStep(chainRpc: chainRpc,
                                                     tokenAddress: tokenAddress,
                                                     ethereumAddress: ethereumAddress,
                                                     spenderAddress: spenderAddress,
                                                     provider: CarteraProvider(),
                                                     walletId: walletId,
                                                     chainIdInt: chainIdInt,
                                                     amount: desiredAmount)
                            .run()
                        }
                    } else if let error = error {
                        return Just(AsyncEvent.result(false, error)).eraseToAnyPublisher()
                    }
                }
                return Empty<AsyncEvent<Void, Bool>, Never>().eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
        }
    }
}
