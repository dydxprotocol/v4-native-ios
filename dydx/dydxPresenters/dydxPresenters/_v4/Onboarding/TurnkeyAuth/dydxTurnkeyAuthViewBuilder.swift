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
        guard let appScheme = Bundle.main.scheme else {
            fatalError((#file as NSString).lastPathComponent + ": Bundle.main.scheme is nil")
        }
        let initialProperties: [String: Any] = [
            // From https://console.cloud.google.com/auth/clients?inv=1&invt=Ab1olg&project=dydx-v4
            "googleClientId": "441463123744-a02e7s84okic2ggqgdo7e7hlgpvkj3p8.apps.googleusercontent.com",
            "appScheme": appScheme,
            "turnkeyUrl": "https://api.turnkey.com",
            // From Turnkey console
            "turnkeyOrgId": "3174ac51-1637-47d8-9456-19549963e2ed",
            // Indexer backend
            "backendApiUrl": "http://dev2-indexer-apne1-lb-public-2076363889.ap-northeast-1.elb.amazonaws.com",
            "theme": dydxThemeSettings.shared.currentThemeType.rnThemeIdentifier
        ]
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
            .init(path: "APP.GENERAL.OR")
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
        // TurnkeyBridgeManager.shared.testFunction()
    }

    // MARK: NavigableProtocol

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

    func onAuthCompleted(onboardingSignature: String, evmAddress: String, svmAddress: String) {
        CosmoJavascript.shared.deriveCosmosKey(signature: onboardingSignature) { [weak self] data in
            if let resultObject = (data as? String)?.jsonDictionary,
               let mnemonic = self?.parser.asString(resultObject["mnemonic"]),
               let cosmoAddress = self?.parser.asString(resultObject["address"]) {

                Router.shared?.navigate(to: RoutingRequest(path: "/action/dismiss"), animated: true) { _, _ in
                    let result = dydxWalletSetup.SetupResult(ethereumAddress: evmAddress,
                                                             walletId: nil,
                                                             cosmoAddress: cosmoAddress,
                                                             mnemonic: mnemonic)
                    dydxOnboardCompletion.finish(walletInstance: nil, result: result)
                }
            } else {
                ErrorInfo.shared?.info(title: "Error", message: "deriveCosmosKey failed", type: .error, error: nil)
            }
        }
    }

    func onAppleAuthRequest(nonce: String) {
        appleSignIn.signInWithApple(nonce: nonce) { identityToken, error in
            TurnkeyBridgeManager.shared.appleSignInCompleted(identityToken: identityToken, error: error?.localizedDescription)
        }
    }
}
