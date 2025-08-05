//
//  dydxWalletSetup.swift
//  dydxCartera
//
//  Created by Rui Huang on 4/24/23.
//

import Foundation
import Cartera
import Combine
import Utilities

public class dydxWalletSetup: WalletStatusDelegate {
    public struct SetupResult {
        public let ethereumAddress: String?
        public let walletId: String?
        public let cosmoAddress: String?
        public let dydxMnemonic: String?
        public let svmAddress: String?
        public let avalancheAddress: String?
        public let sourceWalletMnemonic: String?
        public let loginMethod: String?
        public let userEmail: String?

        public init(ethereumAddress: String? = nil, walletId: String? = nil, cosmoAddress: String? = nil, dydxMnemonic: String? = nil, svmAddress: String? = nil, avalancheAddress: String? = nil, sourceWalletMnemonic: String? = nil, loginMethod: String? = nil, userEmail: String? = nil) {
            self.ethereumAddress = ethereumAddress
            self.walletId = walletId
            self.cosmoAddress = cosmoAddress
            self.dydxMnemonic = dydxMnemonic
            self.svmAddress = svmAddress
            self.avalancheAddress = avalancheAddress
            self.sourceWalletMnemonic = sourceWalletMnemonic
            self.loginMethod = loginMethod
            self.userEmail = userEmail
        }
    }

    public enum Status {
        case idle
        case started
        case connected
        case signed(SetupResult)
        case error(Error)

        static func createError(title: String, message: String = "") -> Self {
            .error(NSError(domain: String(describing: self), code: -1,
                           userInfo: ["title": title, "message": message]))
        }
    }

    @Published public internal(set) var status: Status = .idle
    @Published public internal(set) var debugLink: String?

    let parser = Parser()

    lazy var provider: CarteraProvider = {
        let provider = CarteraProvider()
        provider.walletStatusDelegate = self
        return provider
    }()

    public static func create() {

    }
    public init() {}

    public func startDebugLink(chainId: Int, completion: @escaping WalletConnectCompletion) {
        provider.disconnect()
        provider.startDebugLink(chainId: chainId, completion: completion)
    }

    public func start(walletId: String?,
                      ethereumChainId: Int,
                      signTypedDataAction: String,
                      signTypedDataDomainName: String,
                      useModal: Bool
    ) {
        let wallet = CarteraConfig.shared.wallets.first { $0.id == walletId }
        status = .started
        let request = WalletRequest(wallet: wallet, address: nil, chainId: ethereumChainId, useModal: useModal)
        provider.connect(request: request) { [weak self] info, error in
            if let address = info?.address, error == nil {
                self?.status = .connected
                let walletName = info?.wallet?.name ?? ""
                Tracking.shared?.log(event: "ConnectWallet", data: ["walletType": walletName.uppercased(), "autoReconnect": true])
                self?.sign(wallet: wallet, address: address, ethereumChainId: ethereumChainId, signTypedDataAction: signTypedDataAction, signTypedDataDomainName: signTypedDataDomainName, useModal: useModal)
            } else if let error = error {
                self?.status = .error(error)
                self?.provider.disconnect()
            }
        }
    }

    public func stop() {
        provider.disconnect()
        status = .idle
    }

    func sign(wallet: Wallet?, address: String, ethereumChainId: Int, signTypedDataAction: String, signTypedDataDomainName: String, useModal: Bool) {

    }

    func generatePrivateKey(walletId: String?, privateKeySignature: String, address: String) {
        CosmoJavascript.shared.deriveCosmosKey(signature: privateKeySignature) { [weak self] data in
            if let resultObject = (data as? String)?.jsonDictionary,
               let dydxMnemonic = self?.parser.asString(resultObject["mnemonic"]),
               let cosmoAddress = self?.parser.asString(resultObject["address"]) {
                self?.status = .signed(SetupResult(ethereumAddress: address,
                                                   walletId: walletId,
                                                   cosmoAddress: cosmoAddress,
                                                   dydxMnemonic: dydxMnemonic))
            } else {
                self?.status = Status.createError(title: "deriveCosmosKey failed")
            }
        }
    }

    func typedData(action: String, chainId: Int?, signTypedDataDomainName: String) -> EIP712DomainTypedDataProvider {
        let chainId = chainId ?? 1
        let dydxSign = EIP712DomainTypedDataProvider(name: signTypedDataDomainName, chainId: chainId, version: nil)
        dydxSign.message = message(action: action, chainId: chainId)
        return dydxSign
    }

    func message(action: String, chainId: Int) -> WalletTypedData {
        var definitions = [[String: String]]()
        var data = [String: Any]()
        definitions.append(type(name: "action", type: "string"))
        data["action"] = action

        let message = WalletTypedData(typeName: "dYdX")
        message.definitions = definitions
        message.data = data
        return message
    }

    func type(name: String, type: String) -> [String: String] {
        return ["name": name, "type": type]
    }

    // MARK: WalletStatusDelegate

    public func statusChanged(_ status: Cartera.WalletStatusProtocol) {
        debugLink = status.connectionDeeplink
    }

}
