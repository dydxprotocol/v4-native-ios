//
//  TransferTokenDetails.swift
//  dydxPresenters
//
//  Created by Rui Huang on 23/02/2025.
//

import Foundation
import Combine
import dydxStateManager
import Utilities
import dydxFormatter

final class TransferTokenDetails {
    @Published var selectedToken: TransferTokenInfo?
    @Published var defaultToken: TransferTokenInfo?

    @Published var refreshCounter = 0

    let marketPrices: AnyPublisher<[String: Double], Never> =
        AbacusStateManager.shared.state.marketMap
        .compactMap { marketMap in
            var markets = [String: Double]()
            for marketId in ["ETH-USD", "POL-USD", "SOL-USD", "AVAX-USD"] {
                if let oraclePrice = marketMap[marketId]?.oraclePrice?.doubleValue {
                    markets[marketId] = oraclePrice
                }
            }
            return markets
        }
        .share(replay: 1)
        .eraseToAnyPublisher()

    @Published private var _infos: [TransferTokenInfo] = []

    var currentInfos: [TransferTokenInfo] {
        _infos
    }

    // Chains that supports Turnkey embedded wallet deposit
    var turnkeyInfos: [TransferTokenInfo] {
        _infos.filter {
            $0.token == .USDC
        }
    }

    lazy var infos: AnyPublisher<[TransferTokenInfo], Never> =
        Publishers
            .CombineLatest(
                $_infos.removeDuplicates(),
                marketPrices.removeDuplicates()
            )
            .map { [weak self] infos, marketPrices in
                var newInfos = [TransferTokenInfo]()
                for token in infos {
                    var newToken = token
                    if  token.token == .USDC, token.amount == nil {
                        newToken.amount = newToken.usdcAmount
                    } else if let amount = token.amount, amount > 0 {
                        let key = token.token.rawValue + "-USD"
                        if let marketPrice = marketPrices[key] {
                             newToken.usdcAmount = amount * marketPrice
                        }
                    }
                    newInfos.append(newToken)
                }
                return newInfos.sorted { ($0.usdcAmount ?? 0) > ($1.usdcAmount ?? 0) }
            }
            .share(replay: 1)
            .eraseToAnyPublisher()

    private init(isMainnet: Bool) {
        _infos =  mainnetTokens // isMainnet ? mainnetTokens : testnetTokens
    }

    private static var _shared: TransferTokenDetails?

    static var shared: TransferTokenDetails? {
        _shared
    }

    static func create(isMainnet: Bool) -> TransferTokenDetails {
        let instance = TransferTokenDetails(isMainnet: isMainnet)
        _shared = instance
        return instance
    }

    func update(info: TransferTokenInfo) {
        for i in 0..<_infos.count {
            let existing = _infos[i]
            if info.chainId == existing.chainId, info.tokenAddress == existing.tokenAddress {
                _infos[i] = info
                if selectedToken?.chain == info.chain, selectedToken?.tokenAddress == info.tokenAddress {
                    selectedToken = info
                }
                if defaultToken?.chain == info.chain, defaultToken?.tokenAddress == info.tokenAddress {
                    defaultToken = info
                }
                return
            }
        }
        assertionFailure("Could not find token info to update")
    }

    func refresh() {
        refreshCounter += 1
    }
}

enum TransferChain: String {
    case Ethereum, Optimism, Arbitrum, Base, Polygon, Avalanche, Solana

    var supportedDepositTokenString: String {
        switch self {
        case .Ethereum, .Optimism, .Arbitrum, .Base: return "ETH, USDC"
        case .Polygon: return "POL, USDC"
        case .Solana: return "USDC"
        case .Avalanche: return "USDC"
        }
    }

    var depositFeesString: String {
        switch self {
        case .Ethereum: return DataLocalizer.localize(path: "APP.DEPOSIT_MODAL.FREE_ABOVE", params: ["AMOUNT": "$100"])
        default: return DataLocalizer.localize(path: "APP.GENERAL.FREE")
        }
    }

    var depositWarningString: String? {
        let tokens: String
        switch self {
        case .Ethereum, .Optimism, .Arbitrum, .Base: tokens = "ETH " + DataLocalizer.localize(path: "APP.GENERAL.OR") + " USDC"
        case .Polygon: tokens =  "POL " + DataLocalizer.localize(path: "APP.GENERAL.OR") + " USDC"
        case .Solana: tokens = "USDC"
        case .Avalanche: tokens = "USDC"
        }

        let minSlow: String
        let minFast: String
        let maxVal: String
        switch self {
        case .Ethereum:
            minSlow = dydxTurnkeyDepositParam.eth_min_slow.string
            minFast = dydxTurnkeyDepositParam.eth_min_fast.string
            maxVal = dydxTurnkeyDepositParam.eth_max.string
        case .Arbitrum, .Base, .Optimism, .Polygon, .Solana, .Avalanche:
            minSlow = dydxTurnkeyDepositParam.default_min_slow.string
            minFast = dydxTurnkeyDepositParam.default_min_fast.string
            maxVal = dydxTurnkeyDepositParam.default_max.string
        }

        return DataLocalizer.localize(path: "APP.TURNKEY_ONBOARD.DEPOSIT_NETWORK_WARNING", params: [
            "ASSETS": tokens,
            "NETWORK": rawValue,
            "MIN_DEPOSIT": minSlow,
            "MIN_INSTANT_DEPOSIT": minFast,
            "MAX_DEPOSIT": maxVal
        ])
    }

    var chainLogoUrl: String {
        let logoName: String
        switch self {
        case .Ethereum: logoName = "ethereum.png"
        case .Optimism: logoName = "optimism.png"
        case .Arbitrum: logoName = "arbitrum.png"
        case .Base: logoName = "base.png"
        case .Polygon: logoName = "polygon.png"
        case .Solana: logoName = "solana.png"
        case .Avalanche: logoName = "avalanche.png"
        }
        return AbacusStateManager.shared.deploymentUri + "/chains/\(logoName)"
    }
}

enum TransferToken: String {
    case ETH, USDC, POL, SOL, AVAX
}

struct TransferTokenInfo: Equatable {
    let chain: TransferChain
    let chainId: String

    let token: TransferToken
    let tokenAddress: String

    var amount: Double?
    var usdcAmount: Double?

    var chainLogoUrl: String {
        chain.chainLogoUrl
    }

    var tokenLogoUrl: String {
        let logoName: String
        switch token {
        case .ETH: logoName = "eth.png"
        case .USDC: logoName = "usdc.png"
        case .POL: logoName = "pol.png"
        case .SOL: logoName = "sol.png"
        case .AVAX: logoName = "avax.png"
        }
        return AbacusStateManager.shared.deploymentUri + "/currencies/\(logoName)"
    }

    var decimals: Int {
        switch token {
        case .ETH: return 18
        case .POL: return 18
        case .USDC: return 6
        case .SOL: return 9
        case .AVAX: return 18
        }
    }
}

private let mainnetTokens: [TransferTokenInfo] = [
    TransferTokenInfo(chain: .Ethereum, chainId: "1", token: .USDC, tokenAddress: "0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48"),
    TransferTokenInfo(chain: .Base, chainId: "8453", token: .USDC, tokenAddress: "0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913"),
    TransferTokenInfo(chain: .Optimism, chainId: "10", token: .USDC, tokenAddress: "0x0b2c639c533813f4aa9d7837caf62653d097ff85"),
    TransferTokenInfo(chain: .Arbitrum, chainId: "42161", token: .USDC, tokenAddress: "0xaf88d065e77c8cC2239327C5EDb3A432268e5831"),
    TransferTokenInfo(chain: .Polygon, chainId: "137", token: .USDC, tokenAddress: "0x3c499c542cef5e3811e1192ce70d8cc03d5c3359"),
    TransferTokenInfo(chain: .Avalanche, chainId: "43114", token: .USDC, tokenAddress: "0xB97EF9Ef8734C71904D8002F8b6Bc66Dd9c48a6E"),

    TransferTokenInfo(chain: .Ethereum, chainId: "1", token: .ETH, tokenAddress: "0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE"),
    TransferTokenInfo(chain: .Base, chainId: "8453", token: .ETH, tokenAddress: "0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE"),
    TransferTokenInfo(chain: .Optimism, chainId: "10", token: .ETH, tokenAddress: "0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE"),
    TransferTokenInfo(chain: .Arbitrum, chainId: "42161", token: .ETH, tokenAddress: "0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE"),
    TransferTokenInfo(chain: .Polygon, chainId: "137", token: .POL, tokenAddress: "0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE"),
    TransferTokenInfo(chain: .Avalanche, chainId: "43114", token: .AVAX, tokenAddress: "0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE"),

//    TransferTokenInfo(chain: .Solana, chainId: "solana", token: .SOL, tokenAddress: "solana-native"),
    TransferTokenInfo(chain: .Solana, chainId: "solana", token: .USDC, tokenAddress: "EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v")

]

private let testnetTokens: [TransferTokenInfo] = [
    TransferTokenInfo(chain: .Ethereum, chainId: "11155111", token: .USDC, tokenAddress: "0x482ff112ae0658a014978f53120a64e111e6bedf"),
    TransferTokenInfo(chain: .Base, chainId: "84532", token: .USDC, tokenAddress: "0x0F2559677a6CF88b48BBFAddE1757D4f302C8e23"),
    TransferTokenInfo(chain: .Optimism, chainId: "11155420", token: .USDC, tokenAddress: "0xD0C591da9805D1f801B297bDF46352287E0A6A63"),
    TransferTokenInfo(chain: .Arbitrum, chainId: "421614", token: .USDC, tokenAddress: "0x75faf114eafb1BDbe2F0316DF893fd58CE46AA4d"),
    TransferTokenInfo(chain: .Polygon, chainId: "80002", token: .USDC, tokenAddress: "0x41E94Eb019C0762f9Bfcf9Fb1E58725BfB0e7582"),
    TransferTokenInfo(chain: .Avalanche, chainId: "43113", token: .USDC, tokenAddress: "0x5425890298aed601595a70AB815c96711a31Bc65"),

    TransferTokenInfo(chain: .Ethereum, chainId: "11155111", token: .ETH, tokenAddress: "0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE"),
    TransferTokenInfo(chain: .Base, chainId: "84532", token: .ETH, tokenAddress: "0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE"),
    TransferTokenInfo(chain: .Optimism, chainId: "11155420", token: .ETH, tokenAddress: "0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE"),
    TransferTokenInfo(chain: .Arbitrum, chainId: "421614", token: .ETH, tokenAddress: "0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE"),
    TransferTokenInfo(chain: .Polygon, chainId: "80002", token: .POL, tokenAddress: "0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE"),
    TransferTokenInfo(chain: .Avalanche, chainId: "43113", token: .AVAX, tokenAddress: "0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE"),

//    TransferTokenInfo(chain: .Solana, chainId: "solana-devnet", token: .SOL, tokenAddress: "solana-devnet-native"),
    TransferTokenInfo(chain: .Solana, chainId: "solana-devnet", token: .USDC, tokenAddress: "4zMMC9srt5Ri5X14GAgXhaHii3GnPAEERYPJgZJDncDU")
]
