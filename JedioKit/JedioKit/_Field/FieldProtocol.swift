//
//  FieldDataProtocol.swift
//  FieldInteractorLib
//
//  Created by Qiang Huang on 10/15/18.
//  Copyright © 2018 dYdX. All rights reserved.
//

import ParticlesKit
import Utilities

public protocol FieldProtocol: InteractorProtocol {
    var field: FieldDefinition? { get set }
    var title: String? { get }
    var subtitle: String? { get }
    var text: String? { get }
    var subtext: String? { get }
    var image: String? { get }
    var dependencies: [String: Any]? { get }
}

extension FieldProtocol where Self: NSObject {
    public var title: String? {
        return text(field?.title)
    }

    public var subtitle: String? {
        return text(field?.subtitle)
    }

    public var text: String? {
        return text(field?.text)
    }

    public var subtext: String? {
        return text(field?.subtext)
    }

    public var image: String? {
        return text(field?.image)
    }

    public var dependencies: [String: Any]? {
        return field?.dependencies
    }

    internal func bool(_ definition: [String: Any]?) -> Bool? {
        if let text = text(definition)?.lowercased() {
            if text == "y" || text == "1" || text == "true" || text == "yes" {
                return true
            } else if text == "n" || text == "0" || text == "false" || text == "no" {
                return false
            }
        }
        return nil
    }

    internal func hasData(_ definition: [String: Any]?, textOK: Bool = false) -> Bool {
        if let entity = entity, let definition = definition {
            if let _ = parser.asString(definition["text"]) {
                return textOK
            } else if let field = parser.asString(definition["field"]), let entity = entity as? NSObject, let _ = parser.asString(entity.value(forKey: field)) {
                return true
            }
        }
        return false
    }

    internal func text(_ definition: [String: Any]?) -> String? {
        if let value = textValue(definition), let definition = definition {
            if let options = parser.asDictionary(definition["options"]), let text = parser.asString(options[value]) {
                return text
            } else {
                return value
            }
        }
        return nil
    }

    internal func textValue(_ definition: [String: Any]?) -> String? {
        if let entity = entity as? (NSObject & ModelObjectProtocol), let definition = definition {
            if let text = parser.asString(definition["text"]) {
                return text
            } else if let field = parser.asString(definition["field"]) {
                if let value = entity.value(forKey: field) {
                    switch parser.asString(definition["type"]) {
                    case "bool":
                        return parser.asString(value)

                    case "int":
                        return parser.asNumber(value)?.stringValue

                    case "float":
                        return parser.asNumber(value)?.stringValue

                    case "percent":
                        if let float = parser.asNumber(value)?.floatValue {
                            let percent = float * 100
                            return String(format: "%.2f%%", percent)
                        } else {
                            return nil
                        }

                    case "text":
                        return parser.asString(value)

                    default:
                        return parser.asString(value)
                    }
                }
            }
        }
        return nil
    }

    internal func strings(_ definition: [String: Any]?) -> [String]? {
        if let entity = entity as? (NSObject & ModelObjectProtocol), let definition = definition, let field = parser.asString(definition["field"]) {
            return parser.asStrings(entity.value(forKey: field))
        }
        return nil
    }
}

public protocol FieldOutputProtocol: FieldProtocol {
    var fieldOutput: FieldOutputDefinition? { get }

    var title: String? { get }
    var subtitle: String? { get }

    var text: String? { get }
    var subtext: String? { get }

    var checked: Bool? { get }
    var items: [FieldOutputProtocol]? { get }

    var hasData: Bool { get }
    var visible: Bool { get }
}

extension FieldOutputProtocol {
    public var fieldOutput: FieldOutputDefinition? {
        return field as? FieldOutputDefinition
    }
}

public protocol FieldInputProtocol: FieldProtocol {
    var fieldInput: FieldInputDefinition? { get }

    var string: String? { get set }
    var value: Any? { get set }
    var checked: Bool? { get set }
    var int: Int? { get set }
    var float: Float? { get set }
}

extension FieldInputProtocol {
    public var fieldInput: FieldInputDefinition? {
        return field as? FieldInputDefinition
    }
}
