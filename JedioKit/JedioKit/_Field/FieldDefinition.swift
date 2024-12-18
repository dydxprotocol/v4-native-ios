//
//  FieldOutputDefinition.swift
//  FieldInteractorLib
//
//  Created by Qiang Huang on 10/15/18.
//  Copyright © 2018 dYdX. All rights reserved.
//

import ParticlesKit
import Utilities

@objc open class FieldDefinition: DictionaryEntity {
    public func definition(for field: String) -> [String: Any]? {
        return data?[field] as? [String: Any]
    }

    public func set(definition: [String: Any]?, for field: String) {
        data?[field] = definition
    }

    override open var parser: Parser {
        return Parser.standard
    }
}

public extension FieldDefinition {
    var visible: Bool {
        var visible = parser.asBoolean(data?["visible"])?.boolValue ?? true
        if let featureFlag = parser.asString(data?["featureFlag"]) {
            visible = visible && (FeatureService.shared?.isOn(feature: featureFlag) ?? true)
        }
        return visible
    }

    var title: [String: Any]? {
        return definition(for: "title")
    }

    var subtitle: [String: Any]? {
        return definition(for: "subtitle")
    }

    var text: [String: Any]? {
        return definition(for: "text")
    }

    var subtext: [String: Any]? {
        return definition(for: "subtext")
    }

    var image: [String: Any]? {
        return definition(for: "image")
    }

    var link: [String: Any]? {
        return definition(for: "link")
    }

    var dependencies: [String: Any]? {
        return definition(for: "dependencies")
    }
}

@objc open class FieldOutputDefinition: FieldDefinition {
    public var checked: [String: Any]? {
        return definition(for: "checked")
    }

    public var strings: [String: Any]? {
        return definition(for: "strings")
    }

    public var images: [String: Any]? {
        return definition(for: "images")
    }

    public var items: [FieldOutputDefinition]?

    override open func parse(dictionary: [String: Any]) {
        super.parse(dictionary: dictionary)
        if let items = parser.asArray(dictionary["items"]) as? [[String: Any]] {
            var children = [FieldOutputDefinition]()
            for item in items {
                let child = FieldOutputDefinition()
                child.parse(dictionary: item)
                children.append(child)
            }
            self.items = children
        }
    }
}

public enum FieldType {
    case text
    case strings
    case int
    case float
    case bool
    case percent
    case image
    case images
    case signature
}

public enum FieldValidateType: String {
    case email
    case password
    case phone
    case url
    case creditcard
}

@objc open class FieldInputDefinition: FieldDefinition {
    @objc public dynamic var field: [String: Any]? {
        get {
            return definition(for: "field")
        }
        set {
            set(definition: newValue, for: "field")
        }
    }

    public var fieldType: FieldType {
        switch parser.asString(field?["type"]) {
        case "text":
            return .text

        case "strings":
            return .strings

        case "int":
            return .int

        case "float":
            return .float

        case "bool":
            return .bool

        case "percent":
            return .percent

        case "image":
            return .image

        case "images":
            return .images

        case "signature":
            return .signature

        default:
            return .text
        }
    }

    @objc public dynamic var defaultValue: Any? {
        return field?["default"]
    }

    @objc public dynamic var optional: Bool {
        return parser.asBoolean(field?["optional"])?.boolValue ?? false
    }

    public var validator: FieldValidateType? {
        if let string = parser.asString(field?["validator"]) {
            return FieldValidateType(rawValue: string)
        }
        return nil
    }

    @objc public dynamic var options: [[String: Any]]? {
        get {
            return field?["options"] as? [[String: Any]]
        }
        set {
            willChangeValue(forKey: "options")
            field?["options"] = newValue
            didChangeValue(forKey: "options")
        }
    }

    public var min: Float? {
        return parser.asNumber(field?["min"])?.floatValue
    }

    public var max: Float? {
        return parser.asNumber(field?["max"])?.floatValue
    }

    public func option(for value: Any) -> [String: Any]? {
        return options?.first(where: { (option: [String: Any]) -> Bool in
            if let itemValue = option["value"] {
                if type(of: value) == type(of: itemValue) {
                    if value is String {
                        return value as? String == itemValue as? String
                    } else if value is Int {
                        return value as? Int == itemValue as? Int
                    } else {
                        return false
                    }
                }
            }
            return false
        }) ?? nil
    }

    public func option(labeled label: String) -> [String: Any]? {
        return options?.first(where: { (option: [String: Any]) -> Bool in
            parser.asString(option["text"]) == label
        }) ?? nil
    }
}
