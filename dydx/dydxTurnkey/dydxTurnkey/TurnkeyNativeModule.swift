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

    @objc(onJsResponse::)
    func onJsResponse(_ callbackId: String, _ result: String) {
        if let completion = pendingCompletions[callbackId] {
            completion(result)
            pendingCompletions.removeValue(forKey: callbackId)
        }
    }
}
