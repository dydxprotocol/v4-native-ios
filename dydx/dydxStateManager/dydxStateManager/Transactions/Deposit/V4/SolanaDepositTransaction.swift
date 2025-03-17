//
//  SolanaDepositTransaction.swift
//  dydxStateManager
//
//  Created by Rui Huang on 14/03/2025.
//

import Abacus
import BigInt
import Cartera
import Combine
import Foundation
import Utilities
import Web3
import Base58Swift

struct SolanaDepositTransaction: AsyncStep {
    typealias ProgressType = Void
    typealias ResultType = String

    let payload: TransferInputRequestPayload?
    let provider: CarteraProvider
    let walletAddress: String
    let walletId: String?
    let isMainnet: Bool

    func run() -> AnyPublisher<AsyncEvent<ProgressType, ResultType>, Never> {
        guard let base64Data = payload?.data, let solanaData = Data(base64Encoded: base64Data) else {
            let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid input"])
            return Just(AsyncEvent.result(nil, error)).eraseToAnyPublisher()
        }

        return WalletSendTransactionStep(transaction: nil,
                                         solana: solanaData,
                                         chainIdInt: isMainnet ? 1 : 2,  // anything other than 1 is testnet
                                         provider: provider,
                                         walletAddress: walletAddress,
                                         walletId: walletId)
        .run()
    }
}
