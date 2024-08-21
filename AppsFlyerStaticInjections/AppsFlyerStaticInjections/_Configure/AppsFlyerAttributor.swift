//
//  AppsFlyerInjections.swift
//  AppsFlyerInjections
//
//  Created by Qiang Huang on 7/24/19.
//  Copyright © 2019 dYdX. All rights reserved.
//

import AppsFlyerLib
import PlatformParticles
import Utilities

public final class AppsFlyerAttributor: NSObject, AttributionProtocol {
    public func launch() {
        AppsFlyerLib.shared().start { data, error in
            if let error = error {
                Console.shared.log(error)
            }
            if let data = data {
                Console.shared.log(data)
            }
        }
    }

    // Reports app open from a Universal Link for iOS 9 or later
    public func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) {
        AppsFlyerLib.shared().continue(userActivity, restorationHandler: restorationHandler)
    }

    // Reports app open from deep link from apps which do not support Universal Links (Twitter) and for iOS8 and below
    public func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) {
        AppsFlyerLib.shared().handleOpen(url, sourceApplication: sourceApplication, withAnnotation: annotation)
    }

    // Reports app open from deep link for iOS 10 or later
    public func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any]) {
        AppsFlyerLib.shared().handleOpen(url, options: options)
    }

    public func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) {
        AppsFlyerLib.shared().continue(userActivity, restorationHandler: nil)
    }
}
