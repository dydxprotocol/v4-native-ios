//
//  ParticlesAppDelegate.swift
//  RetslyPlatformParticles
//
//  Created by Qiang Huang on 12/3/18.
//  Copyright © 2018 dYdX. All rights reserved.
//

import ParticlesKit
import PlatformRouting
import RoutingKit
import UIToolkits
import Utilities

#if _iOS
    import COSTouchVisualizer
    import UIAppToolkits
#endif

open class ParticlesAppDelegate: RoutingAppDelegate {
    #if _iOS
        #if _APPCLIP
            open var window: UIWindow?
        #else
            open lazy var window: UIWindow? = {
                if parser.asString(DebugSettings.shared?.debug?["show_touch"]) == "1" {
                    let window = COSTouchVisualizerWindow(frame: UIScreen.main.bounds)
                    window.touchVisualizerWindowDelegate = self
                    window.backgroundColor = UIColor.black
                    return window
                } else {
                    return UIWindow()
                }
            }()
        #endif

    #else
        open lazy var window: UIWindow? = {
            let window = UIWindow()
            window.backgroundColor = UIColor.black
            return window
        }()
    #endif

    override public init() {
        super.init()
        let injection = self.injection()
        Injection.inject(injeciton: injection) {
            ReachabilityMessage.shared.connectivityXib = "Connectivity"
        }
    }

    open func injection() -> ParticlesPlatformAppInjection {
        return ParticlesPlatformAppInjection()
    }

    public func add(tracking: TrackingProtocol) {
        if let composite = Tracking.shared as? CompositeTracking {
            composite.add(tracking)
        } else {
            if let existing = Tracking.shared {
                let composite = compositeTracking()
                composite.add(existing)
                composite.add(tracking)
                Tracking.shared = composite
            } else {
                Tracking.shared = tracking
            }
        }
    }

    open func compositeTracking() -> CompositeTracking {
        return CompositeTracking()
    }

    public func add(errorLogging: ErrorLoggingProtocol) {
        if let composite = ErrorLogging.shared as? CompositeErrorLogging {
            composite.add(errorLogging)
        } else {
            if let existing = ErrorLogging.shared {
                let composite = CompositeErrorLogging()
                composite.add(existing)
                composite.add(errorLogging)
                ErrorLogging.shared = composite
            } else {
                ErrorLogging.shared = errorLogging
            }
        }
    }

    override open func startup(completion: @escaping () -> Void) {
        inject { [weak self] in
            if let self = self {
                #if DEBUG
                    self.add(tracking: DebugTracking())
                    self.add(errorLogging: DebugErrorLogging())
                #else
                #endif
                completion()
            }
        }
    }

    open func inject(completion: @escaping () -> Void) {
        injectFeatures { [weak self] in
            Injection.shared?.injectParsers()
            self?.injectAppStart { [weak self] in
                self?.injectAuth()
                self?.injectLocation()
                completion()
            }
        }
    }

    open func injectFeatures(completion: @escaping () -> Void) {
        Injection.shared?.injectFeatures(completion: completion)
    }

    open func injectAppStart(completion: @escaping () -> Void) {
        Injection.shared?.injectAppStart(completion: completion)
    }

    open func injectAuth() {
    }

    open func injectLocation() {
        Console.shared.log("injectLocation")
//        let locationService = RealLocation()
//        locationService.authorization = LocationPermission.shared
//        LocationProvider.shared = locationService
    }

    override open func routingHistory() -> [RoutingRequest]? {
        return nil
        //        return RoutingHistory.shared.history()
    }

    // Reports app open from deep link for iOS 10 or later
    override open func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        Attributer.shared?.application(application, open: url, options: options)
        return super.application(application, open: url, options: options)
    }

    override open func applicationDidBecomeActive(_ application: UIApplication) {
        super.applicationDidBecomeActive(application)
        Attributer.shared?.launch()
    }

    override open func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        Attributer.shared?.application(application, continue: userActivity, restorationHandler: restorationHandler)
        return super.application(application, continue: userActivity, restorationHandler: restorationHandler)
    }

    // Reports app open from deep link from apps which do not support Universal Links (Twitter) and for iOS8 and below
    override open func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        Attributer.shared?.application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
        return super.application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }

    // Reports app open from a Universal Link for iOS 9 or later
    override open func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        Attributer.shared?.application(application, continue: userActivity, restorationHandler: restorationHandler)
        return super.application(application, continue: userActivity, restorationHandler: restorationHandler)
    }
}

#if _iOS
    extension ParticlesAppDelegate: COSTouchVisualizerWindowDelegate {
        open func touchVisualizerWindowShouldShowFingertip(_ window: COSTouchVisualizerWindow!) -> Bool {
            return true
        }

        open func touchVisualizerWindowShouldAlwaysShowFingertip(_ window: COSTouchVisualizerWindow!) -> Bool {
            return true
        }
    }
#endif
