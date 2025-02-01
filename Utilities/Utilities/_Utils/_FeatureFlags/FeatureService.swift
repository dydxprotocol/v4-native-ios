//
//  FeatureService.swift
//  Utilities
//
//  Created by Qiang Huang on 12/19/18.
//  Copyright © 2019 dYdX. All rights reserved.
//

import Foundation
import Combine

public protocol FeatureFlagsProtocol {

    func refresh(completion: @escaping () -> Void)
    func activate(completion: @escaping () -> Void)
    func value(feature: String) -> String?
    func value<T>(feature: String, defaultValue: T) -> T
    func isOn(feature: String) -> Bool?
    func customized() -> Bool
}

public class FeatureService {
    public static var shared: FeatureFlagsProtocol?
}
