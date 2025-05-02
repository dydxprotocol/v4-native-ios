//
//  dydxPrivyWalletSetup.swift
//  dydxCartera
//
//  Created by Rui Huang on 01/05/2025.
//

import Foundation
import PrivySDK

public final class dydxPrivyWalletSetup: dydxWalletSetup {
    private let privy: Privy?

    public init(privy: Privy?) {
        self.privy = privy
    }

    public func start(wallet: PrivySDK.EmbeddedWallet,
                      walletId: String,
                      signTypedDataAction: String,
                      signTypedDataDomainName: String) {
        guard let privy else {
            status = .error(NSError(domain: String(describing: self), code: -1,
                                                      userInfo: ["title": "Privy", "message": "Privy not available"]))
            return
        }

        let chainId = Int(wallet.chainId ?? "1") ?? 1
        let typeData = typedData(action: signTypedDataAction, chainId: chainId, signTypedDataDomainName: signTypedDataDomainName)
        let request = RpcRequest(method: "eth_signTypedData_v4", params: [wallet.address, typeData.typedDataAsString ?? ""])

        Task {
            do {
                try await privy.embeddedWallet.connectWallet()
                let provider = try privy.embeddedWallet.getEthereumProvider(for: wallet.address)
                let signature = try await provider.request(request)
                generatePrivateKey(walletId: walletId, privateKeySignature: signature, address: wallet.address)
            } catch {
                status = .error(error)
            }
        }
    }
}
