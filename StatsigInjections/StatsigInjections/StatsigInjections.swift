//
//  StatsigInjections.swift
//  StatsigInjections
//
//  Created by Michael Maguire on 7/26/24.
//

import Statsig
import Utilities
import Combine

@objc public final class StatsigFeatureFlagsProvider: NSObject, FeatureFlagsProtocol {

    private let apiKey: String
    private let environment: StatsigEnvironment
    
    public enum Environment {
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
    }
    
    public init(apiKey: String, environment: Environment) {
        self.apiKey = apiKey
        self.environment = environment.statsigEnvironemnt
    }
    
    static public var shared: StatsigFeatureFlagsProvider?
    
    public var featureFlags: [String: Any]?

    public func refresh(completion: @escaping () -> Void) {
        activate(completion: completion)
    }

    public func activate(completion: @escaping () -> Void) {
        if Statsig.isInitialized() {
            completion()
        } else {
            Statsig.start(sdkKey: apiKey, user: StatsigUser(userID: Statsig.getStableID()), options: StatsigOptions(
                initTimeout: nil,
                disableCurrentVCLogging: true,
                environment: environment,
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
                    Console.shared.log("Statsig feature flags initialized")
                    if let error {
//                        assertionFailure("Statsig failed to initialize: \(error)")
                    }
                    self?.newValuesSubject.send()
                    completion()
                }
        }
        completion()
    }
    
    private let newValuesSubject = PassthroughSubject<Void, Never>()
    public var newValuesAvailablePublisher: AnyPublisher<Void, Never> {
        newValuesSubject.eraseToAnyPublisher()
    }

    public func isOn(feature: String) -> Bool? {
        Statsig.checkGate(feature)
    }
    
    public func value(feature: String) -> String? {
        // not yet implemented for Statsig feature flags since it is not yet needed
        return nil
    }

    public func customized() -> Bool {
        return false
    }
}


