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
import Statsig

open class CommonAppDelegate: ParticlesAppDelegate {
    open var notificationTag: String {
        return "firebase"
    }
 
    private lazy var firebaseNotification: FirebaseNotificationHandler = {
        return FirebaseNotificationHandler(tag: notificationTag)
    }()
    
    private let notificationHandlerDelegate = dydxNotificationHandlerDelegate()

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
        // these three injections need to happen before app start
        injectFirebase()
        injectRating()
        injectStatsig()
        let compositeFeatureFlags = CompositeFeatureFlagsProvider()
        switch  Installation.source {
        case .debug, .testFlight:
            compositeFeatureFlags.local = FeatureFlagsStore.shared
        case .appStore, .jailBroken:
            break
        }
        compositeFeatureFlags.remote = FirebaseRunner.shared.enabled ? FirebaseFeatureFlagsProvider() : nil
        FeatureService.shared = compositeFeatureFlags
        FeatureService.shared?.activate { /* [weak self] in */
            Injection.shared?.injectFeatured(completion: completion)
        }
    }

    override open func injectAuth() {
    }

    open func injectUX(completion: @escaping () -> Void) {
        injectGraphingAnchor()
        injectErrorInfo()
        injectAmplitude()
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
        case .debug, .testFlight, .jailBroken: return false
        case .appStore: return true
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
    
    open func injectStatsig() {
        Console.shared.log("injectStatsig")
        if let apiKey = CredientialConfig.shared.key(for: "statsigApiKey"), apiKey.isNotEmpty {
            #if DEBUG
            Statsig.start(sdkKey: apiKey, user: StatsigUser(userID: "test-id"))
            #else
            Statsig.start(sdkKey: apiKey, user: StatsigUser(userID: Statsig.getStableID()))
            #endif
        }
    }

    open func injectAmplitude() {
        Console.shared.log("injectAmplitude")
        let apiKey: String?
        switch Installation.source {
        case .jailBroken, .debug, .testFlight:
            apiKey = CredientialConfig.shared.key(for: "amplitudeStagingApiKey")
        case .appStore:
            apiKey = CredientialConfig.shared.key(for: "amplitudeApiKey")
        }
        if let apiKey = apiKey, apiKey.isNotEmpty {
            AmplitudeRunner.shared.apiKey = apiKey
            add(tracking: dydxAmplitudeTracking())
        }
    }
    
    open func injectAttribution() {
        Console.shared.log("injectAttribution")
        if let devKey = CredientialConfig.shared.key(for: "appsFlyerDevKey"), devKey.isNotEmpty,
           let appId = CredientialConfig.shared.key(for: "appsFlyerAppId"), appId.isNotEmpty {
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
        ParticlesWebView.setup(urlString: CredientialConfig.shared.key(for: "webAppUrl"))
    }

    override open func startup(completion: @escaping () -> Void) {
        injectNotificationHandler()
        injectURLHandler()
        super.startup { [weak self] in
            self?.injectNotification()
            self?.firebaseNotification.delegate = self?.notificationHandlerDelegate
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
