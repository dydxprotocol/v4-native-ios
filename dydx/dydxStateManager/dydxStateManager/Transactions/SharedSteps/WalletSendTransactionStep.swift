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
import Web3

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
            let walletRequest = WalletRequest(wallet: wallet, address: walletAddress, chainId: chainIdInt, useModal: walletId == nil)
            let transactionRequest = WalletTransactionRequest(walletRequest: walletRequest, ethereum: transaction)
            provider.send(request: transactionRequest) { info in
                if info == nil {
                    let error = NSError(domain: "", code: -1, userInfo: [ NSLocalizedDescriptionKey: "Unable to connect to wallet"])
                    _ = subscriber.receive(.result(nil, error))
                }
            } completion: { signed, error in
                if signed != nil {
                    _ = subscriber.receive(.result(signed, nil))
                } else {
                    let walletError = error as? NSError
                    let errorMessage = walletError?.userInfo["message"] as? String
                    if provider.walletStatus?.connectedWallet?.peerName == "MetaMask Wallet", errorMessage == "User rejected." {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            // MetaMask wallet will send a "User rejected" response when switching chain... let's catch it and resend
                            provider.send(request: transactionRequest) { info in
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
                        }
                    } else {
                        _ = subscriber.receive(.result(nil, error))
                    }
                }
            }

            return AnyCancellable {
                // Imperative cancellation implementation
            }
        }
        .eraseToAnyPublisher()
    }
}
