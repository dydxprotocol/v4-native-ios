//
//  dydxReactViewController.swift
//  dydxPresenters
//
//  Created by Rui Huang on 09/04/2025.
//

import Foundation

import UIKit
import React
import React_RCTAppDelegate
import dydxTurnkey

class dydxReactViewController: UIViewController {
    let moduleName: String
    let bundleRoot: String
    var reactNativeFactory: RCTReactNativeFactory?
    var reactNativeFactoryDelegate: RCTReactNativeFactoryDelegate?

    init(moduleName: String, bundleRoot: String = "index") {
        self.moduleName = moduleName
        self.bundleRoot = bundleRoot
        super.init()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        reactNativeFactoryDelegate = ReactNativeDelegate(bundleRoot: bundleRoot)
        reactNativeFactory = RCTReactNativeFactory(delegate: reactNativeFactoryDelegate!)
        view = reactNativeFactory!.rootViewFactory.view(withModuleName: moduleName)
    }
}

class ReactNativeDelegate: RCTDefaultReactNativeFactoryDelegate {
    private let bundleRoot: String

    init(bundleRoot: String) {
        self.bundleRoot = bundleRoot
    }

    override func sourceURL(for bridge: RCTBridge) -> URL? {
        // RCTBridge.current().bundleURL
        TurnkeyBridgeManager.bundleURL
    }

    override func bundleURL() -> URL? {
      #if DEBUG
      RCTBundleURLProvider.sharedSettings().jsBundleURL(forBundleRoot: bundleRoot)
      #else
      Bundle.main.url(forResource: "main", withExtension: "jsbundle")
      #endif
    }
}
