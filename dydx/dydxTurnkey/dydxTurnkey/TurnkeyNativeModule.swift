//
//  TurnkeyNativeModule.swift
//  dydxTurnkey
//
//  Created by Rui Huang on 15/07/2025.
//

import React
import Foundation

@objc class TurnkeyNativeModule: NSObject, RCTBridgeModule {
    public static func moduleName() -> String {
        return "TurnkeyNativeModule"
    }

    private var pendingCompletions: [String: (String) -> Void] = [:]

    func callMyJsFunction(completion: @escaping (String) -> Void) {
        let bridge = TurnkeyBridgeManager.shared.bridge
        let callbackId = UUID().uuidString

        // Store completion for callback correlation
        pendingCompletions[callbackId] = completion

        bridge.enqueueJSCall(
          "RCTDeviceEventEmitter",
          method: "emit",
          args: ["NativeToJsRequest", ["callbackId": callbackId]],
          completion: nil
        )
    }

    @objc public func onJsResponse(_ callbackId: String, _ result: String) {
        if let completion = pendingCompletions[callbackId] {
            completion(result)
            pendingCompletions.removeValue(forKey: callbackId)
        }
    }
}
