//
//  ObjectValueLinePresenter.swift
//  PlatformParticles
//
//  Created by Qiang Huang on 6/10/21.
//  Copyright © 2021 dYdX. All rights reserved.
//

import ParticlesKit

open class ObjectValueLinePresenter: ObjectLinePresenter {
    @objc open dynamic var valueLine: ObjectValueLineInteractor? {
        return model as? ObjectValueLineInteractor
    }

    @objc open dynamic var obj: NSObject? {
        didSet {
            didSetObj(oldValue: oldValue)
        }
    }

    @objc open dynamic var lineValue: Any? {
        didSet {
            didSetLineValue(oldValue: oldValue)
        }
    }

    open var text: String? {
        get {
            if let lineValue = lineValue {
                if let text = formatter?.text(value: lineValue) {
                    return text
                } else {
                    return parser.asString(lineValue)
                }
            } else {
                return nil
            }
        }
        set {
            if let obj = valueLine?.obj2, let valueField = valueLine?.valueField {
                if let newValue = newValue {
                    if let value = formatter?.value(text: newValue) {
                        obj.setValue(value, forKey: valueField)
                    } else {
                        obj.setValue(newValue, forKey: valueField)
                    }
                } else {
                    obj.setValue(nil, forKey: valueField)
                }
            }
        }
    }

    override open func didSetModel(oldValue: ModelObjectProtocol?) {
        super.didSetModel(oldValue: oldValue)
        changeObservation(from: oldValue, to: valueLine, keyPath: #keyPath(ObjectValueLineInteractor.obj2)) { [weak self] _, _, _, _ in
            self?.obj = self?.valueLine?.obj
        }
        changeObservation(from: oldValue, to: valueLine, keyPath: #keyPath(ObjectValueLineInteractor.lineValue)) { [weak self] _, _, _, _ in
            self?.lineValue = self?.valueLine?.lineValue
        }
    }

    open func didSetObj(oldValue: NSObject?) {
    }

    open func didSetLineValue(oldValue: Any?) {
    }
}
