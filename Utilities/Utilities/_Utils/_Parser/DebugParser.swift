//
//  DebugParser.swift
//  Utilities
//
//  Created by John Huang on 7/19/19.
//  Copyright © 2019 dYdX. All rights reserved.
//

import Foundation

public class DebugParser: ConditionalParser {
    @objc public override func conditioned(_ data: Any?) -> Any? {
        var conditions = [String: String]()
        if let debug = DebugSettings.shared?.debug {
            for arg0 in debug {
                let (key, value) = arg0
                conditions[key] = parser.asString(value)
            }
        }
        self.conditions = conditions
        return super.conditioned(data)
    }
}

extension Parser {
    @objc public static var debug: Parser = {
        DebugParser()
    }()
}
