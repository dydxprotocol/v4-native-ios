//
//  TurnkeyBridgeManager.swift
//  dydxTurnkey
//
//  Created by Rui Huang on 14/07/2025.
//

import Foundation
import React

public class TurnkeyBridgeManager {
    public static let shared = TurnkeyBridgeManager()

    public let bridge: RCTBridge

    public static var bundleURL: URL? {
      #if DEBUG
      RCTBundleURLProvider.sharedSettings().jsBundleURL(forBundleRoot: "index")
      #else
      Bundle.main.url(forResource: "main", withExtension: "jsbundle")
      #endif
    }

    private init() {
        bridge = RCTBridge(bundleURL: Self.bundleURL!, moduleProvider: nil, launchOptions: nil)
    }
}
