//
//  ReactNativeView.swift
//  dydxTurnkey
//
//  Created by Rui Huang on 14/07/2025.
//

import SwiftUI
import React

public struct ReactNativeView: UIViewControllerRepresentable {
    let moduleName: String
    let initialProperties: [String: Any]? = nil

    public func makeUIViewController(context: Context) -> ReactNativeHostingController {
        return ReactNativeHostingController(moduleName: moduleName, initialProperties: initialProperties)
    }

    public func updateUIViewController(_ uiViewController: ReactNativeHostingController, context: Context) {
        // No-op
    }
}

// Helper UIViewController that waits for bridge readiness
open class ReactNativeHostingController: UIViewController {
    let moduleName: String
    let initialProperties: [String: Any]?

    private var rootView: RCTRootView?

    public init(moduleName: String, initialProperties: [String: Any]? = nil) {
        self.moduleName = moduleName
        self.initialProperties = initialProperties
        super.init(nibName: nil, bundle: nil)
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open override func viewDidLoad() {
        super.viewDidLoad()

        let bridge = TurnkeyBridgeManager.shared.bridge

        if bridge.isLoading {
            NotificationCenter.default.addObserver(self, selector: #selector(onJSLoaded), name: NSNotification.Name.RCTJavaScriptDidLoad, object: bridge)
        } else {
            setupRootView()
        }
    }

    @objc private func onJSLoaded() {
        setupRootView()
    }

    private func setupRootView() {
        let rootView = RCTRootView(
            bridge: TurnkeyBridgeManager.shared.bridge,
            moduleName: moduleName,
            initialProperties: initialProperties
        )
        rootView.frame = view.bounds
        rootView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(rootView)
        self.rootView = rootView
    }
}

public let turnkeyReactNativeView = ReactNativeView(moduleName: "TurnkeyReact")
