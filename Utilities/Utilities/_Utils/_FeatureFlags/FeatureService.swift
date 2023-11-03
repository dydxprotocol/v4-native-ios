//
//  FeatureService.swift
//  Utilities
//
//  Created by Qiang Huang on 12/19/18.
//  Copyright © 2019 dYdX. All rights reserved.
//

import Foundation

public protocol FeatureFlagsProtocol {
    var featureFlags: [String: Any]? { get }

    func refresh(completion: @escaping () -> Void)
    func activate(completion: @escaping () -> Void)
    func flag(feature: String?) -> Any?
    
    func customized() -> Bool
}

public class FeatureService {
    public static var shared: FeatureFlagsProtocol?
}
