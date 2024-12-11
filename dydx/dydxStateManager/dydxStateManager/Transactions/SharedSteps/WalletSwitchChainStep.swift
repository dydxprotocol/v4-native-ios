//
//  SwitchChainStep.swift
//  dydxStateManager
//
//  Created by Rui Huang on 4/18/23.
//

import Utilities
import Combine
import Abacus
import Cartera

struct WalletSwitchChainStep: AsyncStep {
    typealias ProgressType = Void
    typealias ResultType = Bool

    let transferInput: TransferInput
    let provider: CarteraProvider
    let walletId: String?

    func run() -> AnyPublisher<Utilities.AsyncEvent<ProgressType, ResultType>, Never> {
        AnyPublisher<AsyncEvent<Void, ResultType>, Never>.create { subscriber in
            if let chainId = transferInput.chain,
               let chainIdInt = Parser.standard.asInt(chainId),
               let chainIdHex = String.hex(of: chainIdInt),
               let resource = transferInput.resources?.chainResources?[chainId] {

                let wallet = CarteraConfig.shared.wallets.first { $0.id == walletId } ?? CarteraConfig.shared.wallets.first
                let request = WalletRequest(wallet: wallet, address: nil, chainId: chainIdInt, useModal: walletId == nil)

                provider.connect(request: request) { info, error in
                    if info?.chainId == chainIdInt {
                        // same chainId.. no need to switch
                        _ = subscriber.receive(.result(true, nil))
                    } else if let error = error as? NSError, error.code != CarteraErrorCode.networkMismatch.rawValue {
                        _ = subscriber.receive(.result(false, error))
                    } else {
                        let chainRequest = EthereumAddChainRequest(chainId: chainIdHex,
                                                                   chainName: resource.chainName,
                                                                   rpcUrls: [resource.rpc].filterNils(),
                                                                   iconUrls: [resource.iconUrl].filterNils())
                        provider.addChain(request: request, chain: chainRequest, timeOut: 10) { _ in
                        } completion: { _, error in
                            if let error = error {
                                _ = subscriber.receive(.result(false, error))
                            } else {
                                _ = subscriber.receive(.result(true, nil))
                            }
                        }
                    }
                }

            } else {
                let error = NSError(domain: "", code: -1, userInfo: [ NSLocalizedDescriptionKey: "Invalid transferInput"])
                _ = subscriber.receive(.result(false, error))
            }

            return AnyCancellable {
                // Imperative cancellation implementation
            }
        }
        .eraseToAnyPublisher()
    }
}
