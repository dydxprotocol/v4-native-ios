//
//  TransferTokenDetails.swift
//  dydxPresenters
//
//  Created by Rui Huang on 23/02/2025.
//

import Foundation
import Combine

final class TransferTokenDetails {
    @Published var infos: [TransferTokenInfo] = []

    private init(isMainnet: Bool) {
        infos = isMainnet ? mainnetTokens : testnetTokens
    }

    private static var _shared: TransferTokenDetails?

    static var shared: TransferTokenDetails? {
        _shared
    }

    static func create(isMainnet: Bool) -> TransferTokenDetails? {
        _shared = TransferTokenDetails(isMainnet: isMainnet)
        return _shared
    }
}

struct TransferTokenInfo {
    let chain: String
    let chainId: String
    let token: String
    let tokenAddress: String
    var amount: Double?
    var usdcAmount: Double?
}

private let mainnetTokens: [TransferTokenInfo] = [
    TransferTokenInfo(chain: "Ethereum", chainId: "1", token: "USDC", tokenAddress: "0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48"),
    TransferTokenInfo(chain: "Base", chainId: "8453", token: "USDC", tokenAddress: "0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913"),
    TransferTokenInfo(chain: "Optimism", chainId: "10", token: "USDC", tokenAddress: "0x0b2c639c533813f4aa9d7837caf62653d097ff85"),
    TransferTokenInfo(chain: "Arbitrum", chainId: "42161", token: "USDC", tokenAddress: "0xaf88d065e77c8cC2239327C5EDb3A432268e5831"),
    TransferTokenInfo(chain: "Polygon", chainId: "137", token: "USDC", tokenAddress: "0x3c499c542cef5e3811e1192ce70d8cc03d5c3359"),
    TransferTokenInfo(chain: "Ethereum", chainId: "1", token: "ETH", tokenAddress: "native"),
    TransferTokenInfo(chain: "Base", chainId: "8453", token: "ETH", tokenAddress: "native"),
    TransferTokenInfo(chain: "Optimism", chainId: "10", token: "ETH", tokenAddress: "native"),
    TransferTokenInfo(chain: "Arbitrum", chainId: "42161", token: "ETH", tokenAddress: "native"),
    TransferTokenInfo(chain: "Polygon", chainId: "137", token: "ETH", tokenAddress: "native")
]

private let testnetTokens: [TransferTokenInfo] = [
    TransferTokenInfo(chain: "Ethereum", chainId: "11155111", token: "USDC", tokenAddress: "0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48"),
    TransferTokenInfo(chain: "Base", chainId: "84532", token: "USDC", tokenAddress: "0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913"),
    TransferTokenInfo(chain: "Optimism", chainId: "11155420", token: "USDC", tokenAddress: "0x0b2c639c533813f4aa9d7837caf62653d097ff85"),
    TransferTokenInfo(chain: "Arbitrum", chainId: "421614", token: "USDC", tokenAddress: "0xaf88d065e77c8cC2239327C5EDb3A432268e5831"),
    TransferTokenInfo(chain: "Polygon", chainId: "80002", token: "USDC", tokenAddress: "0x3c499c542cef5e3811e1192ce70d8cc03d5c3359"),
    TransferTokenInfo(chain: "Ethereum", chainId: "11155111", token: "ETH", tokenAddress: "native"),
    TransferTokenInfo(chain: "Base", chainId: "84532", token: "ETH", tokenAddress: "native"),
    TransferTokenInfo(chain: "Optimism", chainId: "11155420", token: "ETH", tokenAddress: "native"),
    TransferTokenInfo(chain: "Arbitrum", chainId: "421614", token: "ETH", tokenAddress: "native"),
    TransferTokenInfo(chain: "Polygon", chainId: "80002", token: "ETH", tokenAddress: "native")
]
