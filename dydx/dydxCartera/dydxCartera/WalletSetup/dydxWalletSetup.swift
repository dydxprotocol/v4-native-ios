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
        public let ethereumAddress: String
        public let walletId: String?
        public let cosmoAddress: String?
        public let mnemonic: String?
        public let apiKey: String?
        public let secret: String?
        public let passPhrase: String?

        init(ethereumAddress: String, walletId: String? = nil, cosmoAddress: String? = nil, mnemonic: String? = nil, apiKey: String? = nil, secret: String? = nil, passPhrase: String? = nil) {
            self.ethereumAddress = ethereumAddress
            self.walletId = walletId
            self.cosmoAddress = cosmoAddress
            self.mnemonic = mnemonic
            self.apiKey = apiKey
            self.secret = secret
            self.passPhrase = passPhrase
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

    // MARK: WalletStatusDelegate

    public func statusChanged(_ status: Cartera.WalletStatusProtocol) {
        debugLink = status.connectionDeeplink
    }

}
