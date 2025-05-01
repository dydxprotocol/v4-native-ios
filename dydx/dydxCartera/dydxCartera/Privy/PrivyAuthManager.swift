//
//  PrivyAuthManager.swift
//  dydxCartera
//
//  Created by Rui Huang on 29/04/2025.
//

import Foundation
import PrivySDK
import Utilities

public class PrivyAuthManager {
    public static var shared: PrivyAuthManager?

    private var currentSession: PrivySDK.AuthSession?

    private var isAuthenticated: Bool {
        currentSession != nil
    }

    private let privy: Privy

    public init(appId: String, appClientId: String) {
        let config = PrivyConfig(
            appId: appId,
            appClientId: appClientId,
            loggingConfig: .init(
                logLevel: .verbose
            )
        )
        privy = PrivySdk.initialize(config: config)
    }

    public func sendEmailCode(email: String) async -> Bool {
        await privy.awaitReady()
        return await privy.email.sendCode(to: email)
    }

    public func loginWithEmail(email: String, code: String) async -> (Bool, Error?) {
        await privy.awaitReady()

        do {
            _ = try await privy.email.loginWithCode(code, sentTo: email)
            return await updateSession()
        } catch {
            currentSession = nil
            return (false, error)
        }
    }

    public func loginGoogle() async {
        await privy.awaitReady()

        currentSession = try? await privy.oAuth.login(with: .google)
     }

    private func updateSession() async -> (Bool, Error?) {
        await privy.awaitReady()

        switch privy.authState {
        case .authenticated(let session):
            currentSession = session
            return (true, nil)
        case .error(let error):
            currentSession = nil
            return (false, error)
        default:
            currentSession = nil
            return (false, nil)
        }
    }
}
