//
//  ConditionalParser.swift
//  Utilities
//
//  Created by John Huang on 7/19/19.
//  Copyright © 2019 dYdX. All rights reserved.
//

import Foundation

public class ConditionalParser: Parser {
    private let defaultTag = "_default"

    public var conditions: [String: String]?

    @objc override open func asString(_ data: Any?) -> String? {
        return super.asString(conditioned(data))
    }

    @objc override open func asStrings(_ data: Any?) -> [String]? {
        return super.asStrings(conditioned(data))
    }

    @objc override open func asNumber(_ data: Any?) -> NSNumber? {
        return super.asNumber(conditioned(data))
    }

    @objc override open func asBoolean(_ data: Any?) -> NSNumber? {
        return super.asBoolean(conditioned(data))
    }

    @objc override open func asDictionary(_ data: Any?) -> [String: Any]? {
        return super.asDictionary(conditioned(data))
    }

    @objc override open func asArray(_ data: Any?) -> [Any]? {
        return super.asArray(conditioned(data))
    }

    @objc override open func conditioned(_ data: Any?) -> Any? {
        if let data = data {
            var conditions = deviceRule().merging(self.conditions ?? [:]) { (string1, _) -> String in
                string1
            }
            if let appInfo = AppConfiguration.info {
                conditions = conditions.merging(appInfo, uniquingKeysWith: { (string1, _) -> String in
                    string1
                })
            }
            return conditioned(data, conditions: conditions)
        }
        return data
    }

    @objc private func deviceRule() -> [String: String] {
        let key = "device"
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            return [key: "phone"]

        case .pad:
            return [key: "pad"]

        case .tv:
            return [key: "tv"]

        case .carPlay:
            return [key: "carPlay"]

        default:
            return [:]
        }
    }

    @objc private func conditioned(_ data: Any, conditions: [String: String]?) -> Any? {
        if let dictionary = super.asDictionary(data) {
            return conditioned(dictionary: dictionary, conditions: conditions) ?? data
        }
        if var string = data as? String, string.contains("<"), string.contains(">"), let conditions = conditions {
            for arg0 in conditions {
                let (key, value) = arg0
                string = string.replacingOccurrences(of: "<\(key)>", with: value)
            }
            return string
        } else {
            return data
        }
    }

    @objc public func conditioned(dictionary: [String: Any], conditions: [String: String]?) -> Any? {
        var narrowedResult: Any?
        if let _ = dictionary.first(where: { (arg0) -> Bool in
            let (key, value) = arg0
            if let node = value as? [String: Any] {
                if let ruleValue = conditions?[key] {
                    narrowedResult = node[ruleValue]
                } else {
                    narrowedResult = node["<null>"]
                }
                if narrowedResult == nil {
                    narrowedResult = node[defaultTag]
                }
            }
            return narrowedResult != nil
        }), let narrowedResult = narrowedResult {
            return conditioned(narrowedResult, conditions: conditions)
        } else {
            return dictionary
        }
    }
}
