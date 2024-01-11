//
//  FirebaseFeatureFlagsProvider.swift
//  FirebaseStaticInjections
//
//  Created by Qiang Huang on 10/3/19.
//  Copyright © 2019 dYdX. All rights reserved.
//

import FirebaseRemoteConfig
import Utilities

@objc public final class FirebaseFeatureFlagsProvider: NSObject, FeatureFlagsProtocol {
    private var remoteConfig: RemoteConfig?
    private var foregroundToken: NotificationToken?

    public var featureFlags: [String: Any]?

    override public init() {
        super.init()
        remoteConfig = RemoteConfig.remoteConfig()
        remoteConfig?.setDefaults(fromPlist: "FeaturesDefaults")
        let settings = RemoteConfigSettings()
        #if DEBUG
            settings.minimumFetchInterval = 0
        #else
            settings.minimumFetchInterval = 60
        #endif
        remoteConfig?.configSettings = settings

        foregroundToken = NotificationCenter.default.observe(notification: UIApplication.willEnterForegroundNotification, do: { [weak self] _ in
            self?.activate {
            }
        })
    }

    public func refresh(completion: @escaping () -> Void) {
        activate(completion: completion)
    }

    public func activate(completion: @escaping () -> Void) {
        if let remoteConfig = remoteConfig {
            remoteConfig.fetchAndActivate(completionHandler: { [weak self] status, _ in
                DispatchQueue.main.async { [weak self] in
                    if status == .successFetchedFromRemote || status == .successUsingPreFetchedData {
                        self?.updateFlags()
                    }
                    completion()
                }
            })
        } else {
            completion()
        }
    }

    public func updateFlags() {
        if let keys = remoteConfig?.allKeys(from: .remote) {
            var flags: [String: Any] = [:]
            for key in keys {
                flags[key] = flag(feature: key)
            }
            featureFlags = flags
        }
    }

    public func flag(feature: String?) -> Any? {
        if let configValue = remoteConfig?.configValue(forKey: feature) {
            if let json = try? JSONSerialization.jsonObject(with: configValue.dataValue) {
                return json
            } else {
                return parser.asString(configValue.stringValue)
            }
        }
        return nil
    }

    public func customized() -> Bool {
        return false
    }
}
