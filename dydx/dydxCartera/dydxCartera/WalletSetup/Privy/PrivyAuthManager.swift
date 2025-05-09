//
//  PrivyAuthManager.swift
//  dydxCartera
//
//  Created by Rui Huang on 29/04/2025.
//

import Foundation
import PrivySDK
import Utilities

public struct PrivyCallStatus {
    public let success: Bool
    public let error: Error?
}

public struct PrivySignStatus {
    public let signature: String?
    public let error: Error?
}

public struct PrivyWalletStatus {
    public let wallet: PrivySDK.EmbeddedWallet?
    public let error: Error?
}

public enum OAuthType {
    case google, twitter, apple

    var privyType: PrivySDK.OAuthProvider {
        switch self {
        case .google:
            return .google
        case .twitter:
            return .twitter
        case .apple:
            return .apple
        }
    }
}

public class PrivyAuthManager {
    public static var shared: PrivyAuthManager?

    @Published public private(set) var isAuthenticated = false

    private var currentSession: PrivySDK.AuthSession? {
        didSet {
            isAuthenticated = currentSession != nil
        }
    }

    public let privy: Privy

    public init(appId: String, appClientId: String) {
        let config = PrivyConfig(
            appId: appId,
            appClientId: appClientId,
            loggingConfig: .init(
                logLevel: .verbose
            )
        )
        privy = PrivySdk.initialize(config: config)
        privy.setAuthStateChangeCallback { [weak self] authState in
            Task {
                await self?.updateSession(authState: authState)
            }
        }

        Task {
            await updateSession()

        }
    }

    public func sendEmailCode(email: String) async -> Bool {
        await privy.awaitReady()
        return await privy.email.sendCode(to: email)
    }

    public func loginWithEmail(email: String, code: String) async -> PrivyCallStatus {
        await privy.awaitReady()

        do {
            let authState = try await privy.email.loginWithCode(code, sentTo: email)
            return await updateSession(authState: authState)
        } catch {
            currentSession = nil
            return PrivyCallStatus(success: false, error: error)
        }
    }

    public func loginOAuth(type: OAuthType) async -> PrivyCallStatus {
        await privy.awaitReady()

        do {
            currentSession = try await privy.oAuth.login(with: type.privyType)
            return await updateSession()
        } catch {
            return PrivyCallStatus(success: false, error: error)
        }
    }

    public func getEmbeddedWallet() async -> PrivyWalletStatus {
        if let user = currentSession?.user {
            for account in user.linkedAccounts {
                switch account {
                case .embeddedWallet(let wallet):
                    return PrivyWalletStatus(wallet: wallet, error: nil)
                default:
                    break
                }
            }
        }

        let walletState = privy.embeddedWallet.embeddedWalletState
        switch walletState {
        case .notCreated:
            do {
                let wallet = try await privy.embeddedWallet.createWallet(chainType: .ethereum)
                return PrivyWalletStatus(wallet: wallet, error: nil)
            } catch {
                return PrivyWalletStatus(wallet: nil, error: error)
            }

        default:
            return PrivyWalletStatus(wallet: nil, error: nil)
        }
    }

    private func updateSession(authState: PrivySDK.AuthState? = nil) async -> PrivyCallStatus {
        await privy.awaitReady()

        switch authState ?? privy.authState {
        case .authenticated(let session):
            currentSession = session
            return PrivyCallStatus(success: true, error: nil)
        case .error(let error):
            currentSession = nil
            return PrivyCallStatus(success: false, error: error)
        default:
            currentSession = nil
            return PrivyCallStatus(success: false, error: nil)
        }
    }
}
