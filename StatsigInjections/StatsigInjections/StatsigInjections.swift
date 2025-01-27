//
//  StatsigInjections.swift
//  StatsigInjections
//
//  Created by Michael Maguire on 7/26/24.
//

import Statsig
import Utilities
import Combine

public final class StatsigFeatureFlagsProvider: NSObject, FeatureFlagsProtocol {
    public enum InitializationState {
        case uninitialized
        case initializedRemoteLoading
        case initializedRemoteLoaded
    }

    private let apiKey: String
    private let userId: String
    private let environment: Environment
    // ensures feature flag values stay constant throughout the app session after they are used the first time, even if they are initialized to null
    private var sessionValues = [String: Availabilty]()

    private enum Availabilty {
        case available(Bool)
        // unavailable is the case for a new feature flag, or a first launch of the app with Statsig
        case unavailable
    }

    public enum Environment: CustomDebugStringConvertible {
        case production
        case development

        var statsigEnvironemnt: StatsigEnvironment {
            switch self {
            case .production:
                return StatsigEnvironment(tier: .Production)
            case .development:
                return StatsigEnvironment(tier: .Development)
            }
        }

        public var debugDescription: String {
            switch self {
            case .production:
                return "production"
            case .development:
                return "development"
            }
        }
    }

    public init(apiKey: String, userId: String, environment: Environment) {
        self.apiKey = apiKey
        self.userId = userId
        self.environment = environment
    }

    static public var shared: StatsigFeatureFlagsProvider?

    public var featureFlags: [String: Any]?

    public func refresh(completion: @escaping () -> Void) {
        activate(completion: completion)
    }

    public func activate(completion: @escaping () -> Void) {
        if Statsig.isInitialized() {
            initializationState = .initializedRemoteLoaded
            completion()
        } else {
            Statsig.start(sdkKey: apiKey, user: StatsigUser(userID: userId, customIDs: ["isNativeApp":"true"]), options: StatsigOptions(
                initTimeout: nil,
                disableCurrentVCLogging: true,
                environment: environment.statsigEnvironemnt,
                enableAutoValueUpdate: true,
                autoValueUpdateIntervalSec: nil,
                overrideStableID: nil,
                enableCacheByFile: nil,
                initializeValues: nil,
                disableDiagnostics: nil,
                disableHashing: nil,
                shutdownOnBackground: nil,
                api: nil,
                eventLoggingApi: nil,
                evaluationCallback: nil,
                userValidationCallback: nil,
                customCacheKey: nil,
                urlSession: nil)) {[weak self] error in
                    Console.shared.log("analytics log | Statsig feature flags finished initial fetch")
                    if let error {
                        Console.shared.log("analytics log | Statsig feature flags finished initial fetch with error: \(error)")
                        return
                    }
                    
                    self?.initializationState = .initializedRemoteLoaded
                    // intentionally not calling completion here since we do not want ff init to be blocking startup
                    // this may change if we need FF pre-launch
//                    completion()
                }
            Console.shared.log("analytics log | Statsig initialized (local only, async feature flags fetch ongoing) | env: \(environment.debugDescription) | userId: \(userId)")
            initializationState = .initializedRemoteLoading
        }
        completion()
    }

    @Published private(set) public var initializationState = InitializationState.uninitialized

    // https://docs.statsig.com/sdk/debugging
    public func isOn(feature: String) -> Bool? {
        let featureGate = Statsig.getFeatureGate(feature)
        let availability: Availabilty
        if let existingAvailability = sessionValues[feature] {
            // a featuregate value has already been set for this session
            availability = existingAvailability
        } else if featureGate.evaluationDetails.reason == .Recognized {
            // a featuregate will be recognized if the feature gate has been fetched in previous Statsig inits (cache is non-empty)
            availability = .available(featureGate.value)
        } else {
            // a featuregate will be unrecognized if the feature gate is new or this is first time initializing Statsig (cache would be empty)
            availability = .unavailable
        }
        sessionValues[feature] = availability
        Console.shared.log("analytics log | Statsig feature flag \(feature) is \(availability) for the session")

        switch availability {
        case .available(let bool):
            return bool
        case .unavailable:
            // defer to calling context for default value
            return nil
        }
    }

    public func value(feature: String) -> String? {
        // not yet implemented for Statsig feature flags since it is not yet needed
        return nil
    }

    public func customized() -> Bool {
        return false
    }
}
