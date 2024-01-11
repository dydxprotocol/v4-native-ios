//
//  ObjectLinesInteractor.swift
//  ParticlesKit
//
//  Created by Qiang Huang on 6/21/21.
//  Copyright © 2021 dYdX. All rights reserved.
//

import Utilities

@objc open class ObjectLinesInteractor: BaseInteractor, InteractorProtocol {
    @objc public dynamic var entity: ModelObjectProtocol? {
        didSet {
            if entity !== oldValue {
                didSetEntity(oldValue: oldValue)
            }
        }
    }

    @objc public dynamic var lines: ListInteractor?

    private lazy var dollarFormatter: ValueFormatterProtocol = DollarValueFormatter()
    private lazy var leverageFormatter: ValueFormatterProtocol = LeverageValueFormatter()
    private lazy var amountFormatter: ValueFormatterProtocol = AmountValueFormatter()
    private lazy var percentFormatter: ValueFormatterProtocol = PercentValueFormatter()

    @objc open dynamic var fields: [String: ObjectLineInteractor]? {
        didSet {
            didSetFields(oldValue: oldValue)
        }
    }

    open var jsonFile: String? {
        return nil
    }

    open func didSetEntity(oldValue: ModelObjectProtocol?) {
        if entity !== oldValue {
            fields = load()
        }
    }

    open func load() -> [String: ObjectLineInteractor]? {
        if let entity = entity, let jsonFile = jsonFile, let json = JsonLoader.load(bundles: Bundle.particles, fileName: jsonFile) as? [String: Any] {
            var fields = [String: ObjectLineInteractor]()
            for (key, value) in json {
                if let fieldJson = value as? [String: Any], let oneField = field(entity: entity, json: fieldJson) {
                    fields[key] = oneField
                }
            }
            return fields
        } else {
            return nil
        }
    }

    open func field(entity: ModelObjectProtocol, json: [String: Any]) -> ObjectLineInteractor? {
        let title = parser.asString(json["title"])
        let xib = parser.asString(json["xib"])
        switch parser.asString(json["type"]) {
        case "options":
            if let strings = json["strings"] as? [String], let options = json["options"] as? [String], let valueField = parser.asString(json["value"]) {
                let objectField = parser.asString(json["object"])
                return self.options(entity: entity, title: title, strings: strings, options: options, objectField: objectField, valueField: valueField, xib: xib)
            } else {
                return nil
            }

        case "bool":
            if let valueField = parser.asString(json["value"]) {
                let objectField = parser.asString(json["object"])
                return boolean(entity: entity, title: title, objectField: objectField, valueField: valueField, xib: xib)
            } else {
                return nil
            }

        case "decimal":
            if let valueField = parser.asString(json["value"]) {
                let format = parser.asString(json["format"])
                let objectField = parser.asString(json["object"])
                return decimal(entity: entity, title: title, formatter: formatter(format: format), objectField: objectField, valueField: valueField, xib: xib)
            } else {
                return nil
            }

        case "string":
            if let valueField = parser.asString(json["value"]) {
                let objectField = parser.asString(json["object"])
                return string(entity: entity, title: title, objectField: objectField, valueField: valueField, xib: xib)
            } else {
                return nil
            }

        case "int":
            if let valueField = parser.asString(json["value"]) {
                let objectField = parser.asString(json["object"])
                return int(entity: entity, title: title, objectField: objectField, valueField: valueField, xib: xib)
            } else {
                return nil
            }

        case "composit":
            if let objectField1 = parser.asString(json["object1"]), let objectField2 = parser.asString(json["object2"]), let valueField1 = parser.asString(json["value1"]), let valueField2 = parser.asString(json["value2"]) {
                let format = parser.asString(json["format"])
                return composit(entity: entity, title: title, formatter: formatter(format: format), objectField1: objectField1, valueField1: valueField1, objectField2: objectField2, valueField2: valueField2, xib: xib)
            } else {
                return nil
            }

        default:
            return nil
        }
    }

    open func formatter(format: String?) -> ValueFormatterProtocol? {
        switch format {
        case "dollar":
            return dollarFormatter

        case "percent":
            return percentFormatter

        case "leverage":
            return leverageFormatter

        case "amount":
            return amountFormatter

        default:
            return nil
        }
    }

    private func composit(entity: ModelObjectProtocol?, title: String?, formatter: ValueFormatterProtocol?, objectField1: String?, valueField1: String, objectField2: String?, valueField2: String, xib: String? = nil) -> ObjectLineInteractor {
        let line1 = decimal(entity: entity, title: nil, formatter: formatter, objectField: objectField1, valueField: valueField1, xib: nil)
        let line2 = decimal(entity: entity, title: nil, formatter: formatter, objectField: objectField2, valueField: valueField2, xib: nil)
        return ObjectCompositeLineInteractor.interactor(entity: entity, title: title, interactor1: line1, interactor2: line2, xib: xib)
    }

    private func options(entity: ModelObjectProtocol?, title: String?, strings: [String], options: [String], objectField: String?, valueField: String, xib: String? = nil) -> ObjectLineInteractor {
        return ObjectOptionsLineInteractor.interactor(entity: entity, title: title, strings: strings, options: options, objectField: objectField, valueField: valueField)
    }

    private func decimal(entity: ModelObjectProtocol?, title: String?, formatter: ValueFormatterProtocol? = nil, objectField: String?, valueField: String, xib: String? = nil) -> ObjectLineInteractor {
        return ObjectDecimalLineInteractor.interactor(entity: entity, title: title, formatter: formatter, objectField: objectField, valueField: valueField, xib: xib)
    }

    private func boolean(entity: ModelObjectProtocol?, title: String?, objectField: String?, valueField: String, xib: String? = nil) -> ObjectLineInteractor {
        return ObjectBooleanLineInteractor.interactor(entity: entity, title: title, objectField: objectField, valueField: valueField, xib: xib)
    }

    private func string(entity: ModelObjectProtocol?, title: String?, objectField: String?, valueField: String, xib: String? = nil) -> ObjectLineInteractor {
        return ObjectStringLineInteractor.interactor(entity: entity, title: title, objectField: objectField, valueField: valueField, xib: xib)
    }

    private func int(entity: ModelObjectProtocol?, title: String?, objectField: String?, valueField: String, xib: String? = nil) -> ObjectLineInteractor {
        return ObjectIntLineInteractor.interactor(entity: entity, title: title, objectField: objectField, valueField: valueField, xib: xib)
    }

    open func didSetFields(oldValue: [String: ObjectLineInteractor]?) {
        updateList()
    }

    public let updateDebouncer = Debouncer()
    open func updateList() {
        let handler = updateDebouncer.debounce()
        handler?.run({ [weak self] in
            self?.reallyUpdateList()
        }, delay: 0.0)
    }

    open func reallyUpdateList() {
    }

    open func add(to: inout [ObjectLineInteractor], key: String) {
        if let field = fields?[key] {
            to.append(field)
        }
    }
}
