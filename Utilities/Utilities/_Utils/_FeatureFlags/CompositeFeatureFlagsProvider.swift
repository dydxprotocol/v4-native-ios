//
//  CompositeFeatureFlagsProvider.swift
//  Utilities
//
//  Created by Qiang Huang on 10/3/19.
//  Copyright © 2019 dYdX. All rights reserved.
//

import Foundation
import Combine

public class CompositeFeatureFlagsProvider: NSObject & FeatureFlagsProtocol {
    public var local: FeatureFlagsProtocol?
    public var remote: FeatureFlagsProtocol?

    public func refresh(completion: @escaping () -> Void) {
        if let local = local {
            local.activate { [weak self] in
                if let remote = self?.remote {
                    remote.refresh(completion: completion)
                } else {
                    completion()
                }
            }
        } else if let remote = remote {
            remote.refresh(completion: completion)
        }
    }

    public func activate(completion: @escaping () -> Void) {
        if let local = local {
            local.activate { [weak self] in
                if let remote = self?.remote {
                    remote.activate(completion: completion)
                } else {
                    completion()
                }
            }
        } else if let remote = remote {
            remote.activate(completion: completion)
        }
    }

    public func value(feature: String) -> String? {
        switch Installation.source {
        case .appStore, .jailBroken:
            return remote?.value(feature: feature)
        case .debug, .testFlight:
            if let localFlag = local?.value(feature: feature) {
                return localFlag
            } else {
                return remote?.value(feature: feature)
            }
        }
    }
   
    public func value<T>(feature: String, defaultValue: T) -> T {
        remote?.value(feature: feature, defaultValue: defaultValue) ?? defaultValue
    }
    
    public func isOn(feature: String) -> Bool? {
        switch Installation.source {
        case .appStore, .jailBroken:
            return remote?.isOn(feature: feature)
        case .debug, .testFlight:
            return local?.isOn(feature: feature) ?? remote?.isOn(feature: feature)
        }
    }

    public func customized() -> Bool {
        return local?.customized() ?? false
    }
}
