//
//  TurnkeyNativeModule.swift
//  dydxTurnkey
//
//  Created by Rui Huang on 15/07/2025.
//

import React
import Foundation

@objc(TurnkeyNativeModule)
public class TurnkeyNativeModule: NSObject, RCTBridgeModule {
    public static func moduleName() -> String! {
        return "TurnkeyNativeModule"
    }

    public static func requiresMainQueueSetup() -> Bool {
      return false
    }

    private var pendingCompletions: [String: (String) -> Void] = [:]

    func callMyJsFunction(completion: @escaping (String) -> Void) {
        let bridge = TurnkeyBridgeManager.shared.bridge
//        guard // let bridge = RCTBridge.current(),
//              let eventEmitter = bridge.module(forName: "RCTDeviceEventEmitter") as? RCTEventEmitter else {
//            print("❗️Bridge or event emitter not ready")
//            completion("Error: bridge not ready")
//            return
//        }

        let callbackId = UUID().uuidString

        // Store completion for callback correlation
        pendingCompletions[callbackId] = completion

        // Emit event to JS side
        // eventEmitter.sendEvent(withName: "NativeToJsRequest", body: ["callbackId": callbackId])

        bridge.enqueueJSCall(
          "RCTDeviceEventEmitter",
          method: "emit",
          args: ["NativeToJsRequest", ["callbackId": callbackId]],
          completion: nil
        )
    }

    @objc
    public func onJsResponse(_ callbackId: String, _ result: String) {
        if let completion = pendingCompletions[callbackId] {
            completion(result)
            pendingCompletions.removeValue(forKey: callbackId)
        }
    }
}
