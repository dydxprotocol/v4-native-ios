//
//  dydxTurnkeyAuthViewBuilder.swift
//  dydxPresenters
//
//  Created by Rui Huang on 23/07/2025.
//

import Utilities
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI
import dydxFormatter
import UIKit
import React
import React_RCTAppDelegate
import dydxTurnkey
import dydxCartera
import dydxViews
import dydxStateManager

public struct OnboardingLandingRoute {
    static var value: String {
        dydxBoolFeatureFlag.turnkey_ios.isEnabled ? "/onboard/turnkey" : "/onboard/wallets"
    }
}

public class dydxTurnkeyAuthViewBuilder: NSObject, ObjectBuilderProtocol {
    public func build<T>() -> T? {
        let viewController = dydxTurnkeyAuthViewConntroller()
        return viewController as? T
    }
}

private class dydxTurnkeyAuthViewConntroller: ReactNativeHostingController, TurnkeyBridgeManagerDelegate, NavigableProtocol {

    private let appleSignIn = AppleSignInManager()

    init() {
        guard let appScheme = Bundle.main.scheme, appScheme != "{APP_SCHEME}" else {
            fatalError((#file as NSString).lastPathComponent + ": Bundle.main.scheme is nil")
        }
        guard let googleClientId = CredientialConfig.shared.credential(for: "googleClientId") else {
            fatalError((#file as NSString).lastPathComponent + ": googleClientId is missing")
        }
        guard let turnkeyOrgId = CredientialConfig.shared.credential(for: "turnkeyOrgId") else {
            fatalError((#file as NSString).lastPathComponent + ": turnkeyOrgId is missing")
        }
        guard let indexerUrl = AbacusStateManager.shared.environment?.endpoints.indexers?.first?.api else {
            fatalError((#file as NSString).lastPathComponent + ": indexerUrl is missing")
        }
        guard let tosUrl = AbacusStateManager.shared.environment?.links?.tos else {
            fatalError((#file as NSString).lastPathComponent + ": tos is missing")
        }
        guard let privacyUrl = AbacusStateManager.shared.environment?.links?.privacy else {
            fatalError((#file as NSString).lastPathComponent + ": privacy is missing")
        }

        let initialProperties: [String: Any] = [
            "googleClientId": googleClientId,
            "appScheme": appScheme,
            "turnkeyUrl": "https://api.turnkey.com",
            "turnkeyOrgId": turnkeyOrgId,
            "backendApiUrl": indexerUrl,
            "deploymentUri": AbacusStateManager.shared.deploymentUri,
            "theme": dydxThemeSettings.shared.currentThemeType.rnThemeIdentifier,
            "enableAppleLoginIn": dydxBoolFeatureFlag.turnkey_ios_apple.isEnabled
        ]

        // The terms string contains HTML links, so we need to construct it here
        let tos = "<a href=\"\(tosUrl)\">\(DataLocalizer.localize(path: "APP.HEADER.TERMS_OF_USE"))</a>"
        let privacy = "<a href=\"\(privacyUrl)\">\(DataLocalizer.localize(path: "APP.ONBOARDING.PRIVACY_POLICY"))</a>"
        let terms = DataLocalizer.localize(
            path: "APP.ONBOARDING.TOS_SHORT",
            params: [
                "TERMS_LINK": tos,
                "PRIVACY_POLICY_LINK": privacy
            ]
        )

        let stringKeys: [DataLocalizer.Entry] = [
            .init(path: "APP.TURNKEY_ONBOARD.SIGN_IN_TITLE"),
            .init(path: "APP.TURNKEY_ONBOARD.SIGN_IN_DESCRIPTION"),
            .init(path: "APP.TURNKEY_ONBOARD.SIGN_IN_PASSKEY"),
            .init(path: "APP.TURNKEY_ONBOARD.SIGN_IN_WALLET"),
            .init(path: "APP.TURNKEY_ONBOARD.SIGN_IN_DESKTOP"),
            .init(path: "APP.TURNKEY_ONBOARD.SUBMIT"),
            .init(path: "APP.TURNKEY_ONBOARD.EMAIL_PLACEHOLDER"),
            .init(path: "APP.TURNKEY_ONBOARD.CHECK_EMAIL_TITLE"),
            .init(path: "APP.TURNKEY_ONBOARD.CHECK_EMAIL_DESCRIPTION"),
            .init(path: "APP.TURNKEY_ONBOARD.RESEND"),
            .init(path: "APP.TURNKEY_ONBOARD.SIGN_IN_GOOGLE"),
            .init(path: "APP.TURNKEY_ONBOARD.SIGN_IN_APPLE"),
            .init(path: "APP.TURNKEY_ONBOARD.SIGN_IN_EMAIL"),
            .init(path: "APP.TURNKEY_ONBOARD.CONTINUE_SIGN_IN_DESCRIPTION"),
            .init(path: "APP.GENERAL.OR"),
            .init(path: "APP.ONBOARDING.TOS_SHORT", localized: terms)
        ]
        super.init(moduleName: "TurnkeyLogin",
                   initialProperties: initialProperties,
                   stringKeys: stringKeys,
                   bridge: TurnkeyBridgeManager.shared.bridge)
    }

    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        TurnkeyBridgeManager.shared.delegate = self
    }

    //
    // MARK: NavigableProtocol
    //

    func navigate(to request: RoutingRequest?, animated: Bool, completion: RoutingKit.RoutingCompletionBlock?) {
        if request?.path == "/onboard/turnkey" {
            if let token = request?.params?["token"] as? String {
                TurnkeyBridgeManager.shared.emailTokenReceived(token: token)
            }
            completion?(nil, true)
        } else {
            completion?(nil, false)
        }
    }

    //
    // MARK: TurnkeyBridgeManagerDelegate
    //

    func onAuthRouteToWallet() {
        Router.shared?.navigate(to: RoutingRequest(path: "/action/dismiss"), animated: true) { _, _ in
            Router.shared?.navigate(to: RoutingRequest(path: "/onboard/wallets", params: [
                "backButtonRoute": "/onboard/turnkey"
            ]), animated: true, completion: nil)
        }
    }

    func onAuthRouteToDesktopQR() {
        Router.shared?.navigate(to: RoutingRequest(path: "/action/dismiss"), animated: true) { _, _ in
            Router.shared?.navigate(to: RoutingRequest(path: "/onboard/scan/instructions"), animated: true, completion: nil)
        }
    }

    func onAuthCompleted(onboardingSignature: String, evmAddress: String, svmAddress: String, mnemonics: String, loginMethod: String, userEmail: String?, dydxAddress: String?) {
        CosmoJavascript.shared.deriveCosmosKey(signature: onboardingSignature) { [weak self] data in
            if let resultObject = (data as? String)?.jsonDictionary,
               let dydxMnemonic = self?.parser.asString(resultObject["mnemonic"]),
               let cosmoAddress = self?.parser.asString(resultObject["address"]) {

                if dydxAddress?.isNotEmpty ?? false {
                    if dydxAddress != cosmoAddress {
                        Tracking.shared?.log(event: "TurnkeyAddressMismatch",
                                             data: [
                                                "turnkeyAddress": dydxAddress ?? "",
                                                "derivedAddress": cosmoAddress,
                                                "loginMethod": loginMethod,
                                                "evmAddress": evmAddress,
                                                "userEmail": (userEmail ?? "")
                                             ])
                        ErrorInfo.shared?.info(title: "Error", message: "dydx address not matching", type: .error, error: nil)
                    } else {
                        self?.completed(evmAddress: evmAddress,
                                        cosmoAddress: cosmoAddress,
                                        dydxMnemonic: dydxMnemonic,
                                        svmAddress: svmAddress,
                                        mnemonics: mnemonics,
                                        loginMethod: loginMethod,
                                        userEmail: userEmail)
                    }
                } else {
                    TurnkeyBridgeManager.shared.uploadDydxAddress(dydxAddress: cosmoAddress) { success, error in
                        if !success {
                            ErrorInfo.shared?.info(title: "Error", message: "dydx address upload failed \(error ?? "")", type: .error, error: nil)
                        } else {
                            self?.completed(evmAddress: evmAddress,
                                            cosmoAddress: cosmoAddress,
                                            dydxMnemonic: dydxMnemonic,
                                            svmAddress: svmAddress,
                                            mnemonics: mnemonics,
                                            loginMethod: loginMethod,
                                            userEmail: userEmail)
                        }
                    }
                }
            } else {
                ErrorInfo.shared?.info(title: "Error", message: "deriveCosmosKey failed", type: .error, error: nil)
            }
        }
    }

    private func completed(evmAddress: String, cosmoAddress: String, dydxMnemonic: String, svmAddress: String, mnemonics: String, loginMethod: String, userEmail: String?
    ) {
        Router.shared?.navigate(to: RoutingRequest(path: "/action/dismiss"), animated: true) { _, _ in
            let result = dydxWalletSetup.SetupResult(ethereumAddress: evmAddress,
                                                     walletId: "turnkey",
                                                     cosmoAddress: cosmoAddress,
                                                     dydxMnemonic: dydxMnemonic,
                                                     svmAddress: svmAddress,
                                                     avalancheAddress: nil,
                                                     sourceWalletMnemonic: mnemonics,
                                                     loginMethod: loginMethod,
                                                     userEmail: userEmail)
            dydxOnboardCompletion.finish(walletInstance: nil, result: result)
        }
    }

    func onAppleAuthRequest(nonce: String) {
        appleSignIn.signInWithApple(nonce: nonce) { identityToken, error in
            TurnkeyBridgeManager.shared.appleSignInCompleted(identityToken: identityToken, error: error?.localizedDescription)
        }
    }
}
