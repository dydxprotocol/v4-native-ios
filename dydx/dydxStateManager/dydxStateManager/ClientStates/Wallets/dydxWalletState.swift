//
//  WalletState.swift
//  dydxStateManager
//
//  Created by Rui Huang on 2/16/23.
//

import Foundation
import Cartera

public struct dydxWalletState: Codable, Equatable {
    private var _wallets: [dydxWalletInstance] = []
    private var _currentWalletId: String?
    private var _currentWalletAddress: String?

    public var wallets: [dydxWalletInstance] {
        _wallets
    }

    public var currentWallet: dydxWalletInstance? {
        _wallets.first { $0.walletId == _currentWalletId && $0.ethereumAddress == _currentWalletAddress }
    }

    private static let storeKey = "AbacusStateManager.WalletState"
    private static let storeType: dydxClientState.StorageType = .keyChain

    public init() {
        let state: dydxWalletState? = dydxClientState.load(storeKey: Self.storeKey, storeType: Self.storeType)
        if let state = state {
            self = state
        }
    }

    public mutating func setCurrentWallet(wallet: dydxWalletInstance) {
        if let existingIndex = _wallets.firstIndex(where: { $0.walletId == wallet.walletId && $0.ethereumAddress == wallet.ethereumAddress }) {
            var existingWallet = _wallets[existingIndex]
            if wallet != existingWallet {
                existingWallet.merge(another: wallet)
                _wallets[existingIndex] = existingWallet
            }
        } else {
            _wallets.insert(wallet, at: 0)
        }
        _currentWalletId = wallet.walletId
        _currentWalletAddress = wallet.ethereumAddress
        dydxClientState.store(state: self, storeKey: Self.storeKey, storeType: Self.storeType)
    }

    /// disconnected the currently connected wallet and connects the next wallet in the inactive wallets array
    public mutating func disconnectAndReplaceCurrentWallet() {
        _wallets = _wallets.filter { $0.walletId != _currentWalletId || $0.ethereumAddress != _currentWalletAddress }

        if let nextWallet = _wallets.first {
            setCurrentWallet(wallet: nextWallet)
        } else {
            dydxClientState.reset(storeType: Self.storeType)
        }
    }
}

public struct dydxWalletInstance: Codable, Equatable {
    public let ethereumAddress: String?
    public let walletId: String?

    // V4
    public var cosmoAddress: String?
    public var mnemonic: String?
    public var subaccountNumber: String?

    // V3
    public var apiKey: String?
    public var secret: String?
    public var passPhrase: String?

    static func V4(ethereumAddress: String?, walletId: String?, cosmoAddress: String, mnemonic: String) -> Self {
        Self.init(ethereumAddress: ethereumAddress, walletId: walletId, cosmoAddress: cosmoAddress, mnemonic: mnemonic)
    }

    static func V3(ethereumAddress: String?, walletId: String?, apiKey: String, secret: String, passPhrase: String) -> Self {
        Self.init(ethereumAddress: ethereumAddress, walletId: walletId, apiKey: apiKey, secret: secret, passPhrase: passPhrase)
    }

    private init(ethereumAddress: String?, walletId: String?, cosmoAddress: String? = nil, mnemonic: String? = nil, subaccountNumber: String? = nil, apiKey: String? = nil, secret: String? = nil, passPhrase: String? = nil) {
        self.ethereumAddress = ethereumAddress
        self.walletId = walletId
        self.cosmoAddress = cosmoAddress
        self.mnemonic = mnemonic
        self.subaccountNumber = subaccountNumber
        self.apiKey = apiKey
        self.secret = secret
        self.passPhrase = passPhrase
    }

    mutating func merge(another: dydxWalletInstance) {
        guard walletId == another.walletId, ethereumAddress == another.ethereumAddress else {
            return
        }

        if let cosmoAddress = another.cosmoAddress {
            self.cosmoAddress = cosmoAddress
        }
        if let mnemonic = another.mnemonic {
            self.mnemonic = mnemonic
        }
        if let subaccountNumber = another.subaccountNumber {
            self.subaccountNumber = subaccountNumber
        }
        if let apiKey = another.apiKey {
            self.apiKey = apiKey
        }
        if let secret = another.secret {
            self.secret = secret
        }
        if let passPhrase = another.passPhrase {
            self.passPhrase = passPhrase
        }
    }

    public var imageUrl: URL? {
        if let id = walletId {
            let carteraWallet = CarteraConfig.shared.wallets.first(where: { wallet in
                wallet.id == walletId
            })
            if let imageName = carteraWallet?.userFields?["imageName"],
               let folder = AbacusStateManager.shared.environment?.walletConnection?.images {
                return URL(string: folder + imageName)
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
}
