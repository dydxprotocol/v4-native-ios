//
//  FieldDefinitionGroup.swift
//  JedioKit
//
//  Created by Qiang Huang on 4/27/19.
//  Copyright © 2019 dYdX. All rights reserved.
//

import ParticlesKit
import Utilities

@objc open class FieldDefinitionGroup: DictionaryEntity {
    override open var parser: Parser {
        return Parser.standard
    }

    public var input: Bool {
        return parser.asBoolean(data?["input"])?.boolValue ?? false
    }

    public var title: String? {
        return parser.asString(data?["title"])
    }

    public var definitions: [FieldDefinition]?

    public func definition(for field: String) -> [String: Any]? {
        return data?[field] as? [String: Any]
    }

    override open func parse(dictionary: [String: Any]) {
        super.parse(dictionary: dictionary)

        if let definitionsData = parser.asArray(data?["fields"]) as? [[String: Any]] {
            var definitions = [FieldDefinition]()
            for itemDictionary in definitionsData {
                let definition = fieldDefinition()
                definition.parse(dictionary: itemDictionary)
                if definition.visible {
                    definitions.append(definition)
                }
            }
            self.definitions = definitions
        }
    }

    open func fieldDefinition() -> FieldDefinition {
        return input ? FieldInputDefinition() : FieldOutputDefinition()
    }

    open func field(entity: ModelObjectProtocol) -> FieldProtocol? {
        return input ? FieldInput() : FieldOutput()
    }

    open func transformToFieldData(entity: ModelObjectProtocol) -> [FieldProtocol]? {
        if let definitions = self.definitions {
            var fields = [FieldProtocol]()
            for definition in definitions {
                if let field = field(entity: entity) {
                    field.field = definition
                    field.entity = entity as? (NSObject & ModelObjectProtocol)
                    fields.append(field)
                    if let items = (field as? FieldOutputProtocol)?.items {
                        for item in items {
                            fields.append(item)
                        }
                    }
                }
            }
            return fields
        }
        return nil
    }

    open func shouldShow(entity: ModelObjectProtocol, field: FieldProtocol) -> Bool {
        var shouldShow = true
        if let dependencies = field.dependencies {
            for arg0 in dependencies {
                if shouldShow {
                    let (key, value) = arg0
                    let string = parser.asString(value)
                    let valueString = parser.asString((entity as? NSObject)?.value(forKey: key))
                    if let string = string {
                        let valueStrings = valueString?.components(separatedBy: ",")
                        shouldShow = valueStrings?.contains(string) ?? false
                    } else {
                        shouldShow = valueString == nil
                    }
                }
            }
        }
        if shouldShow {
            if input {
                return true
            } else {
                if let output = field as? FieldOutputProtocol {
                    if (output as? XibProviderProtocol)?.xib != nil {
                        return true
                    }
                    return output.hasData
                }
                return false
            }
        } else {
            return false
        }
    }
}
