//
//  CommonAppDelegate.swift
//  Trace
//
//  Created by Qiang Huang on 9/15/20.
//  Copyright © 2020 dYdX. All rights reserved.
//

import ParticlesKit
import PlatformParticles
import PlatformRouting
import RoutingKit
import UIAppToolkits
import UIToolkits
import Utilities
import WebParticles

import AmplitudeInjections
import AppsFlyerStaticInjections
import FirebaseStaticInjections
import dydxStateManager
import dydxViews
import dydxAnalytics
import StatsigInjections

open class CommonAppDelegate: ParticlesAppDelegate {
    open var notificationTag: String {
        return "firebase"
    }

    open lazy var firebaseNotification: FirebaseNotificationHandler = {
        return FirebaseNotificationHandler(tag: notificationTag)
    }()

    override open func inject(completion: @escaping () -> Void) {
        super.inject { [weak self] in
            self?.injectUX(completion: completion)
        }
    }

    override open func compositeTracking() -> CompositeTracking {
        return dydxCompositeTracking()
    }

    override open func injectFeatures(completion: @escaping () -> Void) {
        Console.shared.log("injectFeatures")

        // statsig needs to be initialized before FeatureService is initialized
        // because FeatureService sets remote to be StatsigFeatureFlagsProvider.shared
        // TODO: remove the ordering dependency
        injectStatsig()
        let compositeFeatureFlags = CompositeFeatureFlagsProvider()
        switch  Installation.source {
        case .debug, .testFlight:
            compositeFeatureFlags.local = FeatureFlagsStore.shared
        case .appStore, .jailBroken:
            break
        }
        compositeFeatureFlags.remote = StatsigFeatureFlagsProvider.shared
        FeatureService.shared = compositeFeatureFlags
        // at least the amplitude injection needs to happen before app start and after FeatureService is initialized because
        // injectAmplitude triggers abacus initialization which looks at dydxBoolFeatureFlags.force_mainnet
        // TODO: remove the ordering dependency
        injectFirebase()
        injectRating()
        injectAmplitude()
        FeatureService.shared?.activate { /* [weak self] in */
            Injection.shared?.injectFeatured(completion: completion)
        }
    }

    override open func injectAuth() {
    }

    open func injectUX(completion: @escaping () -> Void) {
        injectGraphingAnchor()
        injectErrorInfo()
        injectAttribution()
        injectLocalNotifications()
        injectAppearances()
        injectWebview()

        completion()
    }

    open func injectGraphingAnchor() {
        GraphingAnchor.shared = StandardGraphingAnchor()
    }

    open func useProductionFirebase() -> Bool {
        switch Installation.source {
        case .debug, .jailBroken: return false
        case .appStore, .testFlight: return true
        }
    }

    open func injectFirebase() {
        Console.shared.log("injectFirebase")
        if useProductionFirebase() {
            FirebaseRunner.optionsFile = "GoogleService-Info"
        } else {
            FirebaseRunner.optionsFile = "GoogleService-Info-Staging"
        }
        _ = FirebaseRunner.shared
        if FirebaseRunner.shared.enabled {
            add(tracking: FirebaseTracking())
            add(errorLogging: CrashlyticsErrorLogging())
        }
    }

    open func injectAmplitude() {
        Console.shared.log("injectAmplitude")
        let apiKey: String?
        switch Installation.source {
        case .jailBroken, .debug, .testFlight:
            apiKey = CredientialConfig.shared.credential(for: "amplitudeStagingApiKey")
        case .appStore:
            apiKey = CredientialConfig.shared.credential(for: "amplitudeApiKey")
        }
        let serverZone = CredientialConfig.shared.credential(for: "amplitudeServerZone") ?? "US"
        if let apiKey = apiKey, apiKey.isNotEmpty {
            add(tracking: dydxAmplitudeTracking(apiKey, serverZone: serverZone))
        }
    }

    open func injectStatsig() {
        Console.shared.log("injectStatsig")
        let environment: StatsigFeatureFlagsProvider.Environment
        switch  Installation.source {
        case .debug, .testFlight:
            environment = .development
        case .appStore, .jailBroken:
            environment = .production
        }
        guard let apiKey = CredientialConfig.shared.credential(for: "statsigApiKey") else {
            assertionFailure("Statsig API key is missing")
            return
        }
        StatsigFeatureFlagsProvider.shared = StatsigFeatureFlagsProvider(apiKey: apiKey, userId: dydxCompositeTracking.getStableId(), environment: environment)
    }

    open func injectAttribution() {
        Console.shared.log("injectAttribution")
        if let devKey = CredientialConfig.shared.credential(for: "appsFlyerDevKey"), devKey.isNotEmpty,
           let appId = CredientialConfig.shared.credential(for: "appsFlyerAppId"), appId.isNotEmpty {
            AppsFlyerRunner.shared.devKey = devKey
            AppsFlyerRunner.shared.appId = appId
            Attributer.shared = AppsFlyerAttributor()
            Attributer.shared?.launch()
            add(tracking: AppsFlyerTracking())
        }
    }

    open func injectLocalNotifications() {
        LocalNotificationService.shared = SimpleLocalNotification()
    }

    open func injectErrorInfo() {
        Console.shared.log("injectErrorInfo")
        ErrorInfo.shared = dydxBannerErrorAlert()
    }

    open func injectRating() {
        Console.shared.log("injectRating")
        dydxRatingService.shared = dydxPointsRating()
    }

    open func injectAppearances() {
        Console.shared.log("injectAppearances")
        UINavigationBar.appearance().tintColor = ColorPalette.shared.color(system: "blue")
        UINavigationBar.appearance().shadowColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.2)
        UINavigationBar.appearance().shadowOffset = CGSize(width: 0.0, height: 3.0)
        UINavigationBar.appearance().shadowRadius = 5.0
        UIToolbar.appearance().isTranslucent = false
        UITabBar.appearance().tintColor = ColorPalette.shared.color(system: "blue")
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).backgroundColor = ColorPalette.shared.color(system: "superlight")
    }

    open func injectWebview() {
        ParticlesWebView.setup(urlString: CredientialConfig.shared.credential(for: "webAppUrl"))
    }

    override open func startup(completion: @escaping () -> Void) {
        injectNotificationHandler()
        injectURLHandler()
        super.startup { [weak self] in
            self?.injectNotification()
            completion()
        }
    }

    open override func applicationDidBecomeActive(_ application: UIApplication) {
        super.applicationDidBecomeActive(application)
        Tracking.shared?.log(event: AnalyticsEventV2.AppStart())
        dydxRatingService.shared?.launchedApp()
    }

    open func injectNotification() {
        NotificationService.shared = firebaseNotification
    }

    open func injectNotificationHandler() {
        NotificationBridge.shared = firebaseNotification
    }

    open func injectURLHandler() {
        URLHandler.shared = UIApplication.shared
    }
}
