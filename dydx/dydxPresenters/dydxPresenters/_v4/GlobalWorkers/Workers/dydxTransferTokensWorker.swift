//
//  dydxTransferTokensWorker.swift
//  dydxPresenters
//
//  Created by Rui Huang on 23/02/2025.
//

import Foundation
import Combine
import dydxStateManager
import ParticlesKit
import RoutingKit
import Utilities
import dydxAnalytics
import Abacus
import dydxCartera
import Web3

public final class dydxTransferTokensWorker: BaseWorker {
    private var ethereumInteractors = [String: EthereumInteractor]()

    public override func start() {
        super.start()

        let transferTokenDetails = TransferTokenDetails.create(isMainnet: AbacusStateManager.shared.isMainNet)

        Publishers
            .CombineLatest4(
                AbacusStateManager.shared.state.configs
                    .compactMap { $0?.rpcMap },
                AbacusStateManager.shared.state.currentWallet
                    .compactMap { $0?.ethereumAddress },
                transferTokenDetails.infos.prefix(1),
                transferTokenDetails.$refreshCounter
            )
            .sink { [weak self] rpcMap, ethereumAddress, infos, _ in
                for token in infos {
                    self?.loadTokenInfo(info: token, rpcMap: rpcMap, sourceAddress: ethereumAddress)
                }
            }
            .store(in: &self.subscriptions)

        // set the default
        transferTokenDetails.infos
            .removeDuplicates()
            .sink { tokens in
                if TransferTokenDetails.shared?.defaultToken == nil, let firstToken = tokens.first {
                    TransferTokenDetails.shared?.defaultToken = firstToken
                }
            }
            .store(in: &self.subscriptions)
    }

    private func loadTokenInfo(info: TransferTokenInfo, rpcMap: [String: RpcInfo], sourceAddress: String) {
        guard let address = try? EthereumAddress(hex: sourceAddress, eip55: false) else {
            Console.shared.log("Invalid wallet address")
            return
        }
        guard let rpcInfo = rpcMap[info.chainId] else {
            return
        }

        let ethereumInteractor = ethereumInteractors[rpcInfo.rpcUrl] ??  EthereumInteractor(url: rpcInfo.rpcUrl)
        ethereumInteractors[rpcInfo.rpcUrl] = ethereumInteractor
        if info.tokenAddress == "0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE" {
           ethereumInteractor.eth_getBalance(address: address) { result in
                let tokenDecimals = 18
                switch result.status {
                case .success(let amount):
                    let string = "\(amount.quantity)"
                    let balance = EthConversions.uint256ToHumanTokenString(output: string, decimals: tokenDecimals)
                    var info = info
                    info.amount = Parser.standard.asNumber(balance)?.doubleValue
                    TransferTokenDetails.shared?.update(info: info)
                case .failure(let error):
                    Console.shared.log("Failed to get balance: \(error)")
                }
            }
        } else {
            guard let contract = try? EthereumAddress(hex: info.tokenAddress, eip55: false) else {
                Console.shared.log("Invalid token address")
                return
            }
            let function = ERC20BalanceOfFunction(contract: contract, from: address, account: address)
            if let transaction = try? function.call() {
                ethereumInteractor.eth_call(transaction) { [weak self] result in
                    let tokenDecimals = 6
                    switch result.status {
                    case .success(let data):
                        if let amount = self?.parser.asUInt256(data.ethereumValue().string) {
                            let string = "\(amount)"
                            let balance = EthConversions.uint256ToHumanTokenString(output: string, decimals: tokenDecimals)
                            var info = info
                            let amount = Parser.standard.asNumber(balance)?.doubleValue
                            info.amount = amount
                            info.usdcAmount = amount
                            TransferTokenDetails.shared?.update(info: info)
                        } else {
                            Console.shared.log("Unable to parse response amount")
                        }
                    case .failure(let error):
                        Console.shared.log("Failed to get balance: \(error)")
                    }
                }
            }
        }
    }
}
