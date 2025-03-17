//
//  SolanaInteractor.swift
//  dydxCartera
//
//  Created by Rui Huang on 13/03/2025.
//

import Foundation
import SolanaSwift

public final class SolanaInteractor {
    public static let mainnetEndpoint = APIEndPoint(
        address: "https://api.mainnet-beta.solana.com",
        network: .mainnetBeta
    )

    public static let devnetEndpoint = APIEndPoint(
        address: "https://api.devnet.solana.com",
        network: .devnet
    )

    private let apiClient: JSONRPCAPIClient

    public init(endpoint: APIEndPoint) {
        apiClient = JSONRPCAPIClient(endpoint: endpoint)
    }

    public func getRecentBlockhash() async throws -> String {
        let result = try await apiClient.getRecentBlockhash()
        return result
    }

    public func getSolBalance(account: String) async throws -> UInt64 {
        let result = try await apiClient.getBalance(account: account)
        return result
    }

    public func getUsdcBalance(account: String, tokenAddress: String) async throws -> UInt64 {
        let params = OwnerInfoParams(mint: tokenAddress, programId: nil)
        let configs = RequestConfiguration(encoding: "base64")
        let result = try await apiClient.getTokenAccountsByOwner(pubkey: account,
                                                             params: params,
                                                             configs: configs)
        var balance: UInt64 = 0
        for account in result {
            balance = max(balance, account.account.data.lamports)
        }
        return balance
    }
}
