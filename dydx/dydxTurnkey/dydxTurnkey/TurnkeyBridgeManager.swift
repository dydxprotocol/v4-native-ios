//
//  TurnkeyBridgeManager.swift
//  dydxTurnkey
//
//  Created by Rui Huang on 14/07/2025.
//

import Foundation
import React

public protocol TurnkeyBridgeManagerDelegate: AnyObject {
    func onAuthRouteToWallet()
    func onAuthRouteToDesktopQR()
    func onAuthCompleted(onboardingSignature: String, evmAddress: String, svmAddress: String, mnemonics: String, loginMethod: String, userEmail: String?, dydxAddress: String?)
    func onAppleAuthRequest(nonce: String)
}

public class TurnkeyBridgeManager {
    public static let shared = TurnkeyBridgeManager()

    public weak var delegate: TurnkeyBridgeManagerDelegate? {
        didSet {
            module.delegate = delegate
        }
    }

    public lazy var bridge: RCTBridge = {
        RCTBridge(bundleURL: Self.bundleURL!,
                  moduleProvider: {
            [self.module]
        },
                  launchOptions: nil)
    }()

    public static var bundleURL: URL? {
#if DEBUG
        RCTBundleURLProvider.sharedSettings().jsBundleURL(forBundleRoot: "index")
#else
        Bundle.main.url(forResource: "main", withExtension: "jsbundle")
#endif
    }

    private let module = TurnkeyNativeModule()

    public func testFunction(completion: @escaping (String) -> Void) {
        module.callMyJsFunction(functionName: "NativeToJsRequest") { result in
            print("Result: \(result)")
            completion(result)
        }
    }

    public func appleSignInCompleted(identityToken: String?, error: String?) {
        bridge.enqueueJSCall(
            "RCTDeviceEventEmitter",
            method: "emit",
            args: ["AppleSignInCompleted", ["identityToken": identityToken, "error": error]],
            completion: nil
        )
    }

    public func emailTokenReceived(token: String) {
        bridge.enqueueJSCall(
            "RCTDeviceEventEmitter",
            method: "emit",
            args: ["EmailTokenReceived", ["token": token]],
            completion: nil
        )
    }

    public func uploadDydxAddress(dydxAddress: String, callback: @escaping (Bool, String?) -> Void) {
        module.callMyJsFunction(functionName: "DydxAddressReceived",
                                params: ["dydxAddress": dydxAddress]) { result in
            if result == "success" {
                callback(true, nil)
            } else {
                callback(false, result)
            }
        }
    }

    public func fetchDepositAddresses(dydxAddress: String, indexerUrl: String, callback: @escaping (String?) -> Void) {
        module.callMyJsFunction(functionName: "FetchDepositAddresses",
                                params: ["dydxAddress": dydxAddress,
                                         "indexerUrl": indexerUrl]) { result in
            callback(result)
        }
    }
}
