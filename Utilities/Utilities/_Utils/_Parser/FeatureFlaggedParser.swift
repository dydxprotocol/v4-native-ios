//
//  FeatureFlaggedParser.swift
//  InteractorLib
//
//  Created by John Huang on 11/22/18.
//  Copyright © 2019 dYdX. All rights reserved.
//

import Foundation

public class FeatureFlaggedParser: ConditionalParser {
    @objc override public func conditioned(_ data: Any?) -> Any? {
        var conditions = self.conditions ?? [String: String]()
        if let features = FeatureService.shared?.featureFlags {
            for arg0 in features {
                let (key, value) = arg0
                conditions[key] = parser.asString(value)
            }
        }
        self.conditions = conditions
        return super.conditioned(data)
    }
}

extension Parser {
    @objc public static var featureFlagged: Parser = {
        FeatureFlaggedParser()
    }()
}
