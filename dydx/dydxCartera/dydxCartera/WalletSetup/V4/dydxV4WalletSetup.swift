//
//  dydxV4WalletSetup.swift
//  dydxCartera
//
//  Created by Rui Huang on 3/1/23.
//

import Cartera
import Combine
import Foundation
import Utilities
import Base58Swift

public final class dydxV4WalletSetup: dydxWalletSetup {
     override func sign(wallet: Wallet?, address: String, ethereumChainId: Int, signTypedDataAction: String, signTypedDataDomainName: String, useModal: Bool) {

        let request = WalletRequest(wallet: wallet, address: address, chainId: ethereumChainId, useModal: useModal)
        let typeData = typedData(action: signTypedDataAction, chainId: ethereumChainId, signTypedDataDomainName: signTypedDataDomainName)

        let operationCallback: WalletOperationCompletion = { [weak self] signed, error in
            if let signed = signed, error == nil {
                self?.generatePrivateKey(walletId: wallet?.id, privateKeySignature: signed, address: address)
                self?.provider.disconnect()
            } else if let error = error {
                guard let self else { return }
                let walletError = error as NSError
                let errorMessage = walletError.userInfo["message"] as? String
                if self.provider.walletStatus?.connectedWallet?.peerName == "MetaMask Wallet", errorMessage == "User rejected." {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                        guard let self else { return }
                        // MetaMask wallet will send a "User rejected" response when switching chain... let's catch it and resend
                        self.provider.sign(request: request, typedDataProvider: typeData, connected: nil) { [weak self] signed, error in
                            if let signed = signed, error == nil {
                                self?.generatePrivateKey(walletId: wallet?.id, privateKeySignature: signed, address: address)
                            } else if let error = error {
                                self?.status = .error(error)
                            }
                            self?.provider.disconnect()
                        }
                    }
                } else {
                    self.status = .error(error)
                    self.provider.disconnect()
                }
            }
        }

        if wallet?.id == "phantom-wallet" {
            // Solana only doesn't have structured typed message, so let's just hardcode the message as a string
            // This is the same string used on web
            let message =
    """
    {"domain":{"name":"\(signTypedDataDomainName)"},"message":{"action":"\(signTypedDataAction)"},"primaryType":"dYdX","types":{"dYdX":[{"name":"action","type":"string"}]}}
    """
            provider.signMessage(request: request, message: message, connected: nil) { signed, error in
                if let signed = signed {
                    // The signature from Solana is Base58 encoded
                    if let bytes = Base58.base58Decode(signed) {
                        // Pad a leading zero to make it 65 bytes before passing it down v4-client
                        let data =  Data([0] + bytes)
                        operationCallback(data.hexString, error)
                    } else {
                        operationCallback(signed, error)
                    }
                } else {
                    operationCallback(signed, error)
                }
            }
        } else {
            provider.sign(request: request, typedDataProvider: typeData, connected: nil, completion: operationCallback)
        }
    }
}
