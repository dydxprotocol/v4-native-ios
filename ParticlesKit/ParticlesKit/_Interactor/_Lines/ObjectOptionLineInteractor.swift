//
//  ObjectOptionLineInteractor.swift
//  ParticlesKit
//
//  Created by Qiang Huang on 6/11/21.
//  Copyright © 2021 dYdX. All rights reserved.
//

import Utilities

@objc public class ObjectOptionsLineInteractor: ObjectValueLineInteractor {
    public static func interactor(entity: ModelObjectProtocol?, title: String?, strings: [String], options: [String], objectField: String?, valueField: String, xib: String? = nil) -> ObjectOptionsLineInteractor {
        let interactor = ObjectOptionsLineInteractor()
        interactor.set(entity: entity, title: title, formatter: nil, objectField: objectField, valueField: valueField, xib: xib)
        interactor.strings = strings
        interactor.options = options
        return interactor
    }

    public var strings: [String]?
    private var options: [String]? {
        didSet {
            updateLineValue()
        }
    }

    public var selectionIndex: Int? {
        get {
            return lineValue as? Int
        }
        set {
            if let newValue = newValue, let options = options, let valueField = valueField, newValue < options.count, newValue != selectionIndex {
                let option = options[newValue]
                obj?.setValue(option, forKey: valueField)
            }
        }
    }

    override open func updateLineValue() {
        if let valueField = valueField {
            if let index = index(of: parser.asString(obj?.value(forKey: valueField)), in: options), index != lineValue as? Int {
                lineValue = index
            }
        } else {
            lineValue = nil
        }
    }

    open func index(of value: String?, in options: [String]?) -> Int? {
        if let value = value, let options = options {
            return options.firstIndex(of: value)
        }
        return nil
    }
}
