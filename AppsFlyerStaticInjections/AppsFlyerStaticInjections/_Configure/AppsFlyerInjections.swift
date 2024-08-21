//
//  AppsFlyerInjections.swift
//  AppsFlyerInjections
//
//  Created by Qiang Huang on 7/24/19.
//  Copyright © 2019 dYdX. All rights reserved.
//

import AppsFlyerLib
import Utilities

public final class AppsFlyerRunner: NSObject, SingletonProtocol {
    public static var shared: AppsFlyerRunner = {
        AppsFlyerRunner()
    }()

    public var devKey: String? {
        didSet {
            if devKey != oldValue {
                setup()
            }
        }
    }

    public var appId: String? {
        didSet {
            if appId != oldValue {
                setup()
            }
        }
    }

    private var tracker: AppsFlyerLib? {
        didSet {
            if tracker !== oldValue {
                oldValue?.delegate = nil
                tracker?.delegate = self
                #if DEBUG
                    tracker?.isDebug = true
                #endif
            }
        }
    }

    private func setup() {
        if let devKey = devKey, let appId = appId {
            AppsFlyerLib.shared().appsFlyerDevKey = devKey
            AppsFlyerLib.shared().appleAppID = appId
            tracker = AppsFlyerLib.shared()
        }
    }
}

extension AppsFlyerRunner: AppsFlyerLibDelegate {
    public func onConversionDataSuccess(_ conversionInfo: [AnyHashable: Any]) {
    }

    public func onConversionDataFail(_ error: Error) {
    }

    public func onConversionDataReceived(_ installData: [AnyHashable: Any]) {
        // Handle Conversion Data (Deferred Deep Link)
    }

    public func onConversionDataRequestFailure(_ error: Error?) {
        //    print("\(error)")
    }

    public func onAppOpenAttribution(_ attributionData: [AnyHashable: Any]) {
        // Handle Deep Link Data
    }

    public func onAppOpenAttributionFailure(_ error: Error) {
    }
}
