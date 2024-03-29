//
//  FieldInteractor.swift
//  FieldInteractorLib
//
//  Created by Qiang Huang on 10/15/18.
//  Copyright © 2018 dYdX. All rights reserved.
//

import ParticlesKit
import RoutingKit
import Utilities

@objc public class FieldInput: NSObject, FieldInputProtocol {
    #if _iOS || _tvOS
        private static var emailValicator = { EmailFieldValidator() }()
        private static var phoneValicator = { PhoneFieldValidator() }()
        private static var passwordValidator = { PasswordFieldValidator() }()
    #endif
    private static var nullValidator = { NullFieldValidator() }()

    @objc public dynamic var field: FieldDefinition? {
        didSet {
            if field !== oldValue {
                setDefault()
            }
        }
    }

    @objc public dynamic var entity: ModelObjectProtocol? {
        didSet {
            if entity !== oldValue {
                setDefault()
            }
        }
    }

    public var input: FieldInputDefinition? {
        return field as? FieldInputDefinition
    }

    public var fieldName: String? {
        return parser.asString(fieldInput?.field?["field"])
    }

    public var options: [[String: Any]]? {
        return fieldInput?.options
    }

    public var value: Any? {
        get {
            if let fieldName = fieldName, let entity = entity as? NSObject {
                return parser.asString(entity.value(forKey: fieldName))
            }
            return nil
        }
        set {
            if let fieldName = fieldName {
                (entity as? NSObject)?.setValue(newValue, forKey: fieldName)
            }
            (entity as? DirtyProtocol)?.dirty = true
        }
    }

    public var string: String? {
        get { return parser.asString(value) }
        set { value = newValue }
    }

    public var checked: Bool? {
        get {
            if fieldInput?.fieldType == .bool {
                return bool(fieldInput?.field)
            }
            return nil
        }
        set {
            if fieldInput?.fieldType == .bool {
                if let newValue = newValue {
                    if let option = fieldInput?.option(labeled: newValue ? "yes" : "no") {
                        value = option["value"]
                    }
                } else {
                    value = nil
                }
            }
        }
    }

    public var int: Int? {
        get {
            if fieldInput?.fieldType == .int {
                return parser.asNumber(value)?.intValue
            }
            return nil
        }
        set {
            if fieldInput?.fieldType == .int {
                value = newValue
            }
        }
    }

    public var float: Float? {
        get {
            if fieldInput?.fieldType == .float {
                return parser.asNumber(value)?.floatValue
            }
            return nil
        }
        set {
            if fieldInput?.fieldType == .float {
                value = newValue
            }
        }
    }

    public var percent: Float? {
        get {
            if fieldInput?.fieldType == .percent {
                return parser.asNumber(value)?.floatValue
            }
            return nil
        }
        set {
            if fieldInput?.fieldType == .percent {
                value = newValue
            }
        }
    }

    @objc public dynamic var strings: [String]? {
        get { return string?.components(separatedBy: ",") }
        set { value = newValue?.joined(separator: ",") }
    }

    private var validator: FieldValidatorProtocol? {
        #if _iOS || _tvOS
            switch input?.fieldType {
            case .text?:
                switch input?.validator {
                case .email?:
                    return type(of: self).emailValicator

                case .password?:
                    return type(of: self).passwordValidator

                case .phone?:
                    return type(of: self).phoneValicator

                default:
                    break
                }
            default:
                break
            }
        #endif
        return type(of: self).nullValidator
    }

    public func validate() -> Error? {
        if field?.definition(for: "field") != nil {
            let optional = input?.optional ?? false
            let fieldName = field?.title?["text"] as? String ?? field?.subtext?["text"] as? String ?? ""
            let fieldNameLocalized = DataLocalizer.shared?.localize(path: fieldName, params: nil) ?? fieldName
            return validator?.validate(field: fieldNameLocalized, data: string, optional: optional)
        }
        return nil
    }

    private func setDefault() {
        if let defaultValue = input?.defaultValue, value == nil {
            value = defaultValue
        }
    }
}

extension FieldInput: RoutingOriginatorProtocol {
    public func routingRequest() -> RoutingRequest? {
        if let link = field?.link, let urlString = parser.asString(link["text"]), let url = URL(string: urlString) {
            return RoutingRequest(scheme: url.scheme, host: url.host, path: url.path, params: url.params)
        }
        return nil
    }
}
