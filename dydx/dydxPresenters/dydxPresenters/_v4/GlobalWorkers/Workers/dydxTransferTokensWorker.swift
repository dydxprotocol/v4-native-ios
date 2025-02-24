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

    private let transferTokenDetails: TransferTokenDetails

    private var ethereumInteractors = [String: EthereumInteractor]()

    public override init() {
        transferTokenDetails = TransferTokenDetails.create(isMainnet: AbacusStateManager.shared.isMainNet)

        super.init()
    }

    public override func start() {
        super.start()

        Publishers
            .CombineLatest3(
                AbacusStateManager.shared.state.configs
                    .compactMap { $0?.rpcMap },
                AbacusStateManager.shared.state.currentWallet
                    .compactMap { $0?.ethereumAddress },
                transferTokenDetails.infos.prefix(1)
            )
            .sink { [weak self] rpcMap, ethereumAddress, infos in
                for token in infos {
                    self?.loadTokenInfo(info: token, rpcMap: rpcMap, sourceAddress: ethereumAddress)
                }
            }
            .store(in: &self.subscriptions)

        // set the default
        transferTokenDetails.infos
            .removeDuplicates()
            .sink { [weak self] tokens in
                if self?.transferTokenDetails.defaultToken == nil, let firstToken = tokens.first {
                    self?.transferTokenDetails.defaultToken = firstToken
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
        if info.tokenAddress == "native" {
           ethereumInteractor.eth_getBalance(address: address) { [weak self] result in
                let tokenDecimals = 18
                switch result.status {
                case .success(let amount):
                    let string = "\(amount.quantity)"
                    let balance = EthConversions.uint256ToHumanTokenString(output: string, decimals: tokenDecimals)
                    var info = info
                    info.amount = Parser.standard.asNumber(balance)?.doubleValue
                    self?.transferTokenDetails.update(info: info)
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
                            info.usdcAmount = Parser.standard.asNumber(balance)?.doubleValue
                            self?.transferTokenDetails.update(info: info)
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
