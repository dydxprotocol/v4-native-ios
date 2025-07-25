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
import SolanaSwift

public final class dydxTransferTokensWorker: BaseWorker {
    private var ethereumInteractors = [String: EthereumInteractor]()
    private var solanaInteractor: SolanaInteractor?

    public override func start() {
        super.start()

        let endpoint: APIEndPoint
        let rpcUrl = AbacusStateManager.shared.environment?.endpoints.solanaRpcUrl
        if let rpcUrl {
            endpoint = APIEndPoint(address: rpcUrl, network: AbacusStateManager.shared.isMainNet ? .mainnetBeta : .testnet)
        } else {
            endpoint = AbacusStateManager.shared.isMainNet ? SolanaInteractor.mainnetEndpoint : SolanaInteractor.devnetEndpoint
        }
        solanaInteractor = SolanaInteractor(endpoint: endpoint)

        let transferTokenDetails = TransferTokenDetails.create(isMainnet: AbacusStateManager.shared.isMainNet)

        Publishers
            .CombineLatest4(
                AbacusStateManager.shared.state.configs
                    .compactMap { $0?.rpcMap },
                AbacusStateManager.shared.state.currentWallet
                    .compactMap { $0 },
                transferTokenDetails.infos.prefix(1),
                transferTokenDetails.$refreshCounter
            )
            .sink { [weak self] rpcMap, currentWallet, infos, _ in
                if let ethereumAddress = currentWallet.ethereumAddress {
                    let walletId = currentWallet.walletId
                    for token in infos {
                        if walletId == "phantom-wallet" {
                            self?.loadSolanaTokenInfo(info: token, publicKey: ethereumAddress)
                        } else {
                            self?.loadEthTokenInfo(info: token, rpcMap: rpcMap, sourceAddress: ethereumAddress)
                        }
                    }
                }
            }
            .store(in: &self.subscriptions)

        // set the default
        Publishers
            .CombineLatest(
                transferTokenDetails.infos
                    .removeDuplicates(),
                AbacusStateManager.shared.state.currentWallet
                    .compactMap { $0 }
            )
            .sink { tokens, currentWallet in
                if currentWallet.walletId == "phantom-wallet" {
                    TransferTokenDetails.shared?.defaultToken = tokens.first { token in
                        token.chain == .Solana && token.token == .USDC
                    }
                } else if let firstToken = tokens.first {
                    TransferTokenDetails.shared?.defaultToken = firstToken
                }
            }
            .store(in: &self.subscriptions)
    }

    private func loadSolanaTokenInfo(info: TransferTokenInfo, publicKey: String) {
        if info.chain == .Solana {
            if info.token == .SOL {
                Task {
                    do {
                        let balance = try await solanaInteractor?.getSolBalance(account: publicKey)
                        var info = info
                        info.amount = (Parser.standard.asNumber(balance)?.doubleValue ?? 0) / pow(10.0, Double(info.decimals))
                        DispatchQueue.main.async {
                            TransferTokenDetails.shared?.update(info: info)
                        }
                    } catch {
                        Console.shared.log("Failed to get SOL balance: \(error)")
                        var info = info
                        info.amount = 0
                        DispatchQueue.main.async {
                            TransferTokenDetails.shared?.update(info: info)
                        }
                    }
                }
            } else if info.token == .USDC {
                Task {
                    do {
                        let balance = try await solanaInteractor?.getUsdcBalance(account: publicKey, tokenAddress: info.tokenAddress)
                        var info = info
                        let amount = (Parser.standard.asNumber(balance)?.doubleValue ?? 0) / pow(10.0, Double(info.decimals))
                        info.amount = amount
                        info.usdcAmount = amount
                        DispatchQueue.main.async {
                            TransferTokenDetails.shared?.update(info: info)
                        }
                    } catch {
                        Console.shared.log("Failed to get USDC balance: \(error)")
                        var info = info
                        info.amount = 0
                        info.usdcAmount = 0
                        DispatchQueue.main.async {
                            TransferTokenDetails.shared?.update(info: info)
                        }
                    }
                }
            }
        } else {
            var info = info
            info.amount = 0
            info.usdcAmount = 0
            TransferTokenDetails.shared?.update(info: info)
        }
    }

    private func loadEthTokenInfo(info: TransferTokenInfo, rpcMap: [String: RpcInfo], sourceAddress: String) {
        guard info.chain != .Solana else {
            var info = info
            info.amount = 0
            info.usdcAmount = 0
            TransferTokenDetails.shared?.update(info: info)
            return
        }
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
               let tokenDecimals = info.decimals
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
                    let tokenDecimals = info.decimals
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
