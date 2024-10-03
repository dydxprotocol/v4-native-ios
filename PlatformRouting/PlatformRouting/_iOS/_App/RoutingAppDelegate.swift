//
//  RoutingAppDelegate.swift
//  PlatformRouting
//
//  Created by Qiang Huang on 12/3/18.
//  Copyright © 2018 dYdX. All rights reserved.
//

import RoutingKit
import UIKit
import Utilities

open class RoutingAppDelegate: UIResponder, UIApplicationDelegate {
    #if _iOS
        private var shortcut: UIApplicationShortcutItem?
        private var deeplink: URL?
    #endif

    private var started: Bool = false

    open func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        #if _iOS
            shortcut = launchOptions?[UIApplication.LaunchOptionsKey.shortcutItem] as? UIApplicationShortcutItem
        #endif

        startup { [weak self] in
            NotificationBridge.shared?.launched()
            if let self = self {
                self.route { [weak self] in
                    self?.started = true
                    self?.handleDeeplink()
                }
            }
        }
        return true
    }

    open func startup(completion: @escaping () -> Void) {
        completion()
    }

    open func route(completion: @escaping () -> Void) {
        Router.shared = router()

        routeToStart(completion: completion)
    }

    open func router() -> RouterProtocol? {
        let router = MappedUIKitAppRouter(file: "routing.json")
        router.appState = AppState.shared
        return router
    }

    #if _iOS
        open func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
            shortcut = shortcutItem
        }
    #endif

    // Reports app open from deep link from apps which do not support Universal Links (Twitter) and for iOS8 and below
    open func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        deeplink = url
        return true
    }

    open func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        deeplink = url
        return true
    }

    open func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        if let url = userActivity.webpageURL {
            deeplink = url
        }
        return true
    }

    // Reports app open from a Universal Link for iOS 9 or later
    open func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        if let url = userActivity.webpageURL {
            deeplink = url
        }
        return true
    }

    open func applicationDidBecomeActive(_ application: UIApplication) {
        #if _iOS
            handleDeeplink()
        #endif
    }

    /// Prioritized handling of the deeplink
    /// - Parameter url: the deeplink url to handle
    /// - Returns: true if the custom handling handled the url
    open func customHandle(url: URL) -> Bool {
        return false
    }

    open func handleDeeplink() {
        if started {
            if let urlString = shortcut?.type, let url = URL(string: urlString) {
                Router.shared?.navigate(to: url, completion: nil)
                shortcut = nil
            } else if let url = deeplink {
                if !customHandle(url: url) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        Router.shared?.navigate(to: url) { [weak self] _, successful in
                            self?.deepLinkHandled(deeplink: url, successful: successful)
                        }
                    }
                }
                deeplink = nil
            }
        }
    }

    open func deepLinkHandled(deeplink: URL, successful: Bool) { }

    open func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        NotificationBridge.shared?.registered(deviceToken: deviceToken)
    }

    open func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        NotificationBridge.shared?.failed(error: error)
    }

    open func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if started {
            NotificationBridge.shared?.received(userInfo: userInfo, fetchCompletionHandler: completionHandler)
        } else {
            deeplink = NotificationBridge.shared?.receivedDeeplink(userInfo: userInfo)
        }
    }

    open func routingHistory() -> [RoutingRequest]? {
        // RoutingHistory.shared.history()
        return nil
    }

    open func routeToStart(completion: @escaping () -> Void) {
        if let history = routingHistory() {
            navigate(to: history, index: 0) { _, _ in
                completion()
            }
        } else {
            Router.shared?.navigate(to: RoutingRequest(path: "/"), animated: true, completion: { _, _ in
                Router.shared?.navigate(to: RoutingRequest(path: "/authorization/notification"), animated: true, completion: { _, _ in
                    completion()
                })
            })
        }
    }

    open func navigate(to history: [RoutingRequest], index: Int, completion: RoutingCompletionBlock?) {
        if index < history.count {
            Router.shared?.navigate(to: history[index], animated: true, completion: { [weak self] _, completed in
                if completed {
                    self?.navigate(to: history, index: index + 1, completion: completion)
                }
            })
        } else {
            completion?(self, true)
        }
    }
}
