//
//  ReactNativeHostingController.swift
//  dydxViews
//
//  Created by Rui Huang on 31/07/2025.
//

import SwiftUI
import React
import PlatformUI
import Utilities

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

open class ReactNativeHostingController: UIViewController {
    let moduleName: String
    let initialProperties: [String: Any]?
    let stringKeys: [DataLocalizer.Entry]
    let bridge: RCTBridge

    private var rootView: RCTRootView?

    public init(moduleName: String, initialProperties: [String: Any]? = nil, stringKeys: [DataLocalizer.Entry] = [], bridge: RCTBridge) {
        self.moduleName = moduleName
        self.initialProperties = initialProperties
        self.stringKeys = stringKeys
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
        var strings = [String: String]()
        for entry in stringKeys {
            strings[entry.path] = entry.localized ?? DataLocalizer.localize(path: entry.path, params: entry.params)
        }
        var props: [String: Any] = (initialProperties ?? [:])
        props["strings"] = strings

        let rootView = RCTRootView(
            bridge: bridge,
            moduleName: moduleName,
            initialProperties: props
        )
        rootView.frame = view.bounds
        rootView.backgroundColor = ThemeColor.SemanticColor.layer0.uiColor
        rootView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(rootView)
        self.rootView = rootView
    }
}
