//
//  WalletSendTransactionStep.swift
//  dydxStateManager
//
//  Created by Rui Huang on 4/18/23.
//

import Utilities
import Combine
import Abacus
import Cartera
import BigInt
import web3

struct WalletSendTransactionStep: AsyncStep {
    typealias ProgressType = Void
    typealias ResultType = String

    let transaction: EthereumTransactionRequest
    let chainIdInt: Int
    let provider: CarteraProvider
    let walletAddress: String
    let walletId: String?

    func run() -> AnyPublisher<Utilities.AsyncEvent<ProgressType, ResultType>, Never> {
        AnyPublisher<AsyncEvent<Void, ResultType>, Never>.create { subscriber in
            let wallet = CarteraConfig.shared.wallets.first { $0.id == walletId } ?? CarteraConfig.shared.wallets.first
            let walletRequest = WalletRequest(wallet: wallet, address: walletAddress, chainId: chainIdInt)
            let transactinoRequest = WalletTransactionRequest(walletRequest: walletRequest, ethereum: transaction)
            provider.send(request: transactinoRequest) { info in
                if info == nil {
                    let error = NSError(domain: "", code: -1, userInfo: [ NSLocalizedDescriptionKey: "Unable to connect to wallet"])
                    _ = subscriber.receive(.result(nil, error))
                }
            } completion: { signed, error in
                if signed != nil {
                    _ = subscriber.receive(.result(signed, nil))
                } else {
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
