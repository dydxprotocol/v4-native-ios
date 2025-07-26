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
    func onAuthCompleted(onboardingSignature: String, evmAddress: String, svmAddress: String)
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

    public func testFunction() {
        module.callMyJsFunction { result in
            print("Result: \(result)")
        }
    }
}
