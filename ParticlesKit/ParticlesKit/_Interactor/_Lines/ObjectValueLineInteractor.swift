//
//  ObjectValueLineInteractor.swift
//  ParticlesKit
//
//  Created by Qiang Huang on 6/10/21.
//  Copyright © 2021 dYdX. All rights reserved.
//

import Utilities

@objc open class ObjectValueLineInteractor: ObjectLineInteractor {
    @IBInspectable open dynamic var objectField: String? {
        didSet {
            if objectField != oldValue {
                if let oldValue = oldValue {
                    changeObservation(from: entity, to: nil, keyPath: oldValue) { _, _, _, _ in
                    }
                }
                if let objectField = objectField {
                    changeObservation(from: nil, to: entity, keyPath: objectField) { [weak self] _, _, _, _ in
                        self?.updateObject()
                    }
                }
            }
        }
    }

    @IBInspectable open dynamic var object2Field: String? {
        didSet {
            if object2Field != oldValue {
                if let oldValue = oldValue {
                    changeObservation(from: obj, to: nil, keyPath: oldValue) { _, _, _, _ in
                    }
                }
                if let object2Field = object2Field {
                    changeObservation(from: nil, to: obj, keyPath: object2Field) { [weak self] _, _, _, _ in
                        self?.updateObject2()
                    }
                }
            }
        }
    }

    @IBInspectable open dynamic var valueField: String? {
        didSet {
            if valueField != oldValue {
                if let oldValue = oldValue {
                    changeObservation(from: obj2, to: nil, keyPath: oldValue) { _, _, _, _ in
                    }
                }
                if let valueField = valueField {
                    changeObservation(from: nil, to: obj2, keyPath: valueField) { [weak self] _, _, _, _ in
                        self?.updateLineValue()
                    }
                }
            }
        }
    }

    @objc open dynamic var obj: NSObject? {
        didSet {
            if let object2Field = object2Field {
                changeObservation(from: oldValue, to: obj, keyPath: object2Field) { [weak self] _, _, _, _ in
                    self?.updateObject2()
                }
            } else {
                updateObject2()
            }
        }
    }

    @objc open dynamic var obj2: NSObject? {
        didSet {
            if let valueField = valueField {
                changeObservation(from: oldValue, to: obj, keyPath: valueField) { [weak self] _, _, _, _ in
                    self?.updateLineValue()
                }
            } else {
                updateLineValue()
            }
        }
    }

    @objc open dynamic var lineValue: Any?

    override open func didSetEntity(oldValue: ModelObjectProtocol?) {
        super.didSetEntity(oldValue: oldValue)
        if let objectField = objectField {
            changeObservation(from: oldValue, to: entity, keyPath: objectField) { [weak self] _, _, _, _ in
                self?.updateObject()
            }
        } else {
            updateObject()
        }
    }

    open func updateObject() {
        if let objectField = objectField, objectField != "self" {
            obj = (entity as? NSObject)?.value(forKey: objectField) as? NSObject
        } else {
            obj = entity as? NSObject
        }
    }

    open func updateObject2() {
        if let object2Field = object2Field, object2Field != "self" {
            obj2 = obj?.value(forKey: object2Field) as? NSObject
        } else {
            obj2 = obj
        }
    }

    open func updateLineValue() {
        if let valueField = valueField {
            lineValue = obj?.value(forKey: valueField)
        } else {
            lineValue = nil
        }
    }

    public func set(entity: ModelObjectProtocol?, title: String?, formatter: ValueFormatterProtocol?, objectField: String?, valueField: String, xib: String? = nil) {
        self.title = title
        self.formatter = formatter
        self.objectField = objectField
        self.valueField = valueField
        self.xib = xib
        self.entity = entity
    }
}

@objc public class ObjectDecimalLineInteractor: ObjectValueLineInteractor {
    public static func interactor(entity: ModelObjectProtocol?, title: String?, formatter: ValueFormatterProtocol? = nil, objectField: String?, valueField: String, xib: String? = nil) -> ObjectDecimalLineInteractor {
        let interactor = ObjectDecimalLineInteractor()
        interactor.set(entity: entity, title: title, formatter: formatter, objectField: objectField, valueField: valueField, xib: xib)
        return interactor
    }

    public var decimal: NSNumber? {
        return parser.asDecimal(lineValue)
    }
}

@objc public class ObjectIntLineInteractor: ObjectValueLineInteractor {
    public static func interactor(entity: ModelObjectProtocol?, title: String?, objectField: String?, valueField: String, xib: String? = nil) -> ObjectIntLineInteractor {
        let interactor = ObjectIntLineInteractor()
        interactor.set(entity: entity, title: title, formatter: nil, objectField: objectField, valueField: valueField, xib: xib)
        return interactor
    }

    public var int: NSNumber? {
        return parser.asNumber(lineValue)
    }
}

@objc public class ObjectBooleanLineInteractor: ObjectValueLineInteractor {
    public static func interactor(entity: ModelObjectProtocol?, title: String?, objectField: String?, valueField: String, xib: String? = nil) -> ObjectBooleanLineInteractor {
        let interactor = ObjectBooleanLineInteractor()
        interactor.set(entity: entity, title: title, formatter: nil, objectField: objectField, valueField: valueField, xib: xib)
        return interactor
    }

    public var boolean: NSNumber? {
        return parser.asBoolean(lineValue)
    }
}

@objc public class ObjectStringLineInteractor: ObjectValueLineInteractor {
    public static func interactor(entity: ModelObjectProtocol?, title: String?, objectField: String?, valueField: String, xib: String? = nil) -> ObjectStringLineInteractor {
        let interactor = ObjectStringLineInteractor()
        interactor.set(entity: entity, title: title, formatter: nil, objectField: objectField, valueField: valueField, xib: xib)
        return interactor
    }

    public var string: String? {
        return parser.asString(lineValue)
    }
}

@objc public class ObjectWebLineInteractor: ObjectValueLineInteractor {
    public static func interactor(entity: ModelObjectProtocol?, title: String?, objectField: String?, valueField: String, xib: String? = nil) -> ObjectWebLineInteractor {
        let interactor = ObjectWebLineInteractor()
        interactor.set(entity: entity, title: title, formatter: nil, objectField: objectField, valueField: valueField, xib: xib)
        return interactor
    }

    public var url: String? {
        return parser.asString(lineValue)
    }
}
