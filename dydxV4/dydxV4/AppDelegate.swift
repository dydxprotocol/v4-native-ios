//
//  AppDelegate.swift
//  dydx
//
//  Created by Qiang Huang on 10/8/18.
//  Copyright © 2018 dYdX. All rights reserved.
//

import Cartera
import CoinbaseWalletSDK
import Combine
import dydxFormatter
import dydxPresenters
import dydxStateManager
import dydxViews
import ParticlesKit
import PlatformParticles
import PlatformRouting
import PlatformUI
import RoutingKit
import UIAppToolkits
import UIToolkits
import Utilities
import dydxAnalytics

#if _iOS
    import FirebaseStaticInjections
    import Foundation
    import UIKit
#endif

public class dydxAppInjection: ParticlesPlatformAppInjection {
    override open func injectFolderService() {
        super.injectFolderService()
        (FolderService.shared as? RealFolderProvider)?.documentFolder = Directory.document?.stringByAppendingPathComponent(path: "dydx")
    }
}

@UIApplicationMain
class AppDelegate: CommonAppDelegate {
    private var subscriptions = Set<AnyCancellable>()
    private let workers = dydxGlobalWorkers()

    private lazy var notificationHandlerDelegate = dydxNotificationHandlerDelegate()

    override public init() {
        super.init()
        LocalAuthenticator.shared = dydxBiometricsLocalAuthenticator()
        SettingsStore.shared = dydxSettingsStore()
        DebugSettings.shared = SettingsStore.shared
        FeatureFlagsStore.shared = FeatureFlagsStore(tag: "FeatureFlags")
    }

    override open func injectAppStart(completion: @escaping () -> Void) {
        Exporter.shared = EmailExporter()
        super.injectAppStart(completion: completion)
    }

    open func cleanUp() {
        let flagTag = "cleaning_flag1"
        let flag = UserDefaults.standard.bool(forKey: flagTag)
        if !flag {
            let defaults = UserDefaults.standard
            let dictionary = defaults.dictionaryRepresentation()
            dictionary.keys.forEach { key in
                defaults.removeObject(forKey: key)
            }
            UserDefaults.standard.set(true, forKey: flagTag)
            if let document = Directory.document {
                Directory.delete(document)
            }
        }
    }

    override open func injection() -> ParticlesPlatformAppInjection {
        cleanUp()
        return ParticlesPlatformAppInjection()
    }

    override public func routeToStart(completion: @escaping () -> Void) {
        DataLocalizer.shared = dydxAbacusDataLocalizer(keyValueStore: SettingsStore.shared)
        firebaseNotification.delegate = notificationHandlerDelegate
        workers.start()

        let localCompletion = {
            // This gets called after passing the security/login screen
            completion()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) { [weak self] in
            guard let self = self else {
                return
            }

            Publishers.CombineLatest(
                AbacusStateManager.shared.state.walletState,
                AbacusStateManager.shared.state.restriction)
                .prefix(1)
                .sink { walletState, restriction in
                    defer { dydxRestrictionsWorker.handle(restriction: restriction) }
                    if walletState.currentWallet != nil, !UIDevice.current.isSimulator {
                        let params = ["securityCompleted": localCompletion]
                        Router.shared?.navigate(to: RoutingRequest(path: "/security_at_launch", params: params), animated: true, completion: nil)
                    } else {
                        Router.shared?.navigate(to: RoutingRequest(path: "/"), animated: true) { _, _ in
                            localCompletion()
                        }
                    }
                }
                .store(in: &self.subscriptions)

            //            _ = dydxAppUpdateInteractor.shared
            //
            //            if dydxBoolFeatureFlag.push_notification.isEnabled {
            //                _ = dydxNotificationConfigsInteractor.shared
            //            }
        }
    }

    override open func injectAppearances() {
        Console.shared.log("injectAppearances")

        dydxThemeLoader.updateTheme()

        ParticilesKitConfig.xibJson = "xib_swiftui.json"

        UITabBar.appearance().barTintColor = UIColor.clear
        UITabBar.appearance().backgroundColor = UIColor.clear
    }

    override func router() -> RouterProtocol? {
        let routingFile = "routing_swiftui.json"

        let scheme = Bundle.main.scheme ?? "dydx-t-v4"
        if let file = Bundle.dydxPresenters.path(forResource: routingFile, ofType: ""),
           let jsonString = try? String(contentsOfFile: file).replacingOccurrences(of: "{APP_SCHEME}", with: scheme) {
            let router = MappedUIKitAppRouter(jsonString: jsonString)
            router.appState = AppState.shared
            // sets up web app routing path
            if let url = URL(string: AbacusStateManager.shared.deploymentUri),
               let host = url.host {
                router.aliases?[host] = router.defaults?["host"]
            }
            return router
        } else {
            return nil
        }
    }

    override func deepLinkHandled(deeplink: URL, successful: Bool) {
        Tracking.shared?.log(event: AnalyticsEventV2.DeepLinkHandled(url: deeplink.absoluteString, succeeded: successful))
    }

    /// Prioritized CoinbaseWalletSDK handling of the deeplink
    /// - Parameter url: the deeplink url to handle
    /// - Returns: true if the CoinbaseWalletSDK handled the url
    override func customHandle(url: URL) -> Bool {
        do {
            if try CoinbaseWalletSDK.shared.handleResponse(url) == true {
                return true
            }
            return false
        } catch {
            // Coinbase SDK throwing error -> URL is still considered handled.
            Console.shared.log("Coinbase SDK throwing error: \(error)")
            return true
        }
    }
}
