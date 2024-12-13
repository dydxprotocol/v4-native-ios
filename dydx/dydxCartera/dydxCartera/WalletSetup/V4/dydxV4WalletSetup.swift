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

public final class dydxV4WalletSetup: dydxWalletSetup {
    private let parser = Parser()

    override func sign(wallet: Wallet?, address: String, ethereumChainId: Int, signTypedDataAction: String, signTypedDataDomainName: String, useModal: Bool) {
        let request = WalletRequest(wallet: wallet, address: address, chainId: ethereumChainId, useModal: useModal)
        let typeData = typedData(action: signTypedDataAction, chainId: ethereumChainId, signTypedDataDomainName: signTypedDataDomainName)
        provider.sign(request: request, typedDataProvider: typeData, connected: nil) { [weak self] signed, error in
            if let signed = signed, error == nil {
                self?.generatePrivateKey(wallet: wallet, privateKeySignature: signed, address: address)
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
                                self?.generatePrivateKey(wallet: wallet, privateKeySignature: signed, address: address)
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
    }

    private func generatePrivateKey(wallet: Wallet?, privateKeySignature: String, address: String) {
        CosmoJavascript.shared.deriveCosmosKey(signature: privateKeySignature) { [weak self] data in
            if let resultObject = (data as? String)?.jsonDictionary,
               let mnemonic = self?.parser.asString(resultObject["mnemonic"]),
               let cosmoAddress = self?.parser.asString(resultObject["address"]) {
                self?.status = .signed(SetupResult(ethereumAddress: address,
                                                   walletId: wallet?.id,
                                                   cosmoAddress: cosmoAddress,
                                                   mnemonic: mnemonic))
            } else {
                self?.status = Status.createError(title: "deriveCosmosKey failed")
            }
        }
    }

    private func typedData(action: String, chainId: Int?, signTypedDataDomainName: String) -> EIP712DomainTypedDataProvider {
        let chainId = chainId ?? 1
        let dydxSign = EIP712DomainTypedDataProvider(name: signTypedDataDomainName, chainId: chainId, version: nil)
        dydxSign.message = message(action: action, chainId: chainId)
        return dydxSign
    }

    private func message(action: String, chainId: Int) -> WalletTypedData {
        var definitions = [[String: String]]()
        var data = [String: Any]()
        definitions.append(type(name: "action", type: "string"))
        data["action"] = action

        let message = WalletTypedData(typeName: "dYdX")
        message.definitions = definitions
        message.data = data
        return message
    }

    private func type(name: String, type: String) -> [String: String] {
        return ["name": name, "type": type]
    }
}
