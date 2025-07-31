//
//  ReactNativeHostingController.swift
//  dydxViews
//
//  Created by Rui Huang on 31/07/2025.
//

import SwiftUI
import React
import PlatformUI

public struct ReactNativeView: UIViewControllerRepresentable {
    let moduleName: String
    let initialProperties: [String: Any]? = nil
    let bridge: RCTBridge

    public func makeUIViewController(context: Context) -> ReactNativeHostingController {
        return ReactNativeHostingController(moduleName: moduleName, initialProperties: initialProperties, bridge: bridge)
    }

    public func updateUIViewController(_ uiViewController: ReactNativeHostingController, context: Context) {
        // No-op
    }
}

// Helper UIViewController that waits for bridge readiness
open class ReactNativeHostingController: UIViewController {
    let bridge: RCTBridge
    let moduleName: String
    let initialProperties: [String: Any]?

    private var rootView: RCTRootView?

    public init(moduleName: String, initialProperties: [String: Any]? = nil, bridge: RCTBridge) {
        self.moduleName = moduleName
        self.initialProperties = initialProperties
        self.bridge = bridge
        super.init(nibName: nil, bundle: nil)
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open override func viewDidLoad() {
        super.viewDidLoad()

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
            bridge: bridge,
            moduleName: moduleName,
            initialProperties: initialProperties
        )
        rootView.frame = view.bounds
        rootView.backgroundColor = ThemeColor.SemanticColor.layer0.uiColor
        rootView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(rootView)
        self.rootView = rootView
    }
}
