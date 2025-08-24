//
//  TurnkeyNativeModule.swift
//  dydxTurnkey
//
//  Created by Rui Huang on 15/07/2025.
//

import React
import Foundation

@objc(TurnkeyNativeModule)
class TurnkeyNativeModule: NSObject, RCTBridgeModule {
    static func moduleName() -> String {
        return "TurnkeyNativeModule"
    }

    static func requiresMainQueueSetup() -> Bool {
      return false
    }

    weak var delegate: TurnkeyBridgeManagerDelegate?

    private var pendingCompletions: [String: (String) -> Void] = [:]

    func callMyJsFunction(functionName: String,
                          params: [String: String] = [:],
                          completion: @escaping (String) -> Void) {
        let bridge = TurnkeyBridgeManager.shared.bridge
        let callbackId = UUID().uuidString

        // Store completion for callback correlation
        pendingCompletions[callbackId] = completion

        var params = params
        params["callbackId"] = callbackId

        bridge.enqueueJSCall(
          "RCTDeviceEventEmitter",
          method: "emit",
          args: [functionName, params],
          completion: nil
        )
    }

    @objc(onJsResponse::)
    func onJsResponse(_ callbackId: String, _ result: String) {
        if let completion = pendingCompletions[callbackId] {
            DispatchQueue.main.async {
                completion(result)
            }
            pendingCompletions.removeValue(forKey: callbackId)
        }
    }

    @objc(onAuthRouteToWallet)
    func onAuthRouteToWallet() {
        DispatchQueue.main.async { [weak self] in
            self?.delegate?.onAuthRouteToWallet()
        }
    }

    @objc(onAuthRouteToDesktopQR)
    func onAuthRouteToDesktopQR() {
        DispatchQueue.main.async { [weak self] in
            self?.delegate?.onAuthRouteToDesktopQR()
        }
    }

    @objc(onAuthCompleted::::::)
    func onAuthCompleted(onboardingSignature: String, evmAddress: String, svmAddress: String, mnemonics: String, loginMethod: String, userEmail: String?) {
        DispatchQueue.main.async { [weak self] in
            self?.delegate?.onAuthCompleted(onboardingSignature: onboardingSignature, evmAddress: evmAddress, svmAddress: svmAddress, mnemonics: mnemonics, loginMethod: loginMethod, userEmail: userEmail)
        }
    }

    @objc(onAppleAuthRequest:)
    func onAppleAuthRequest(nonce: String) {
        DispatchQueue.main.async { [weak self] in
            self?.delegate?.onAppleAuthRequest(nonce: nonce)
        }
    }
}
