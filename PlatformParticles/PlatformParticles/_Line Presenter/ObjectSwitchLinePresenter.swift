//
//  ObjectSwitchLinePresenter.swift
//  PlatformParticles
//
//  Created by Qiang Huang on 6/10/21.
//  Copyright © 2021 dYdX. All rights reserved.
//

import UIToolkits
import Utilities

open class ObjectSwitchLinePresenter: ObjectValueLinePresenter {
    @IBOutlet var checkbox: UISwitch? {
        didSet {
            if checkbox !== oldValue {
                oldValue?.removeTarget()
                checkbox?.add(target: self, action: #selector(check(_:)), for: UIControl.Event.valueChanged)
            }
        }
    }

    override open func didSetLineValue(oldValue: Any?) {
        let on = (lineValue as? NSNumber)?.boolValue ?? false
        if checkbox?.isOn != on {
            checkbox?.isOn = on
        }
    }

    @IBAction func check(_ sender: Any?) {
        if let isOn = checkbox?.isOn, let valueField = valueLine?.valueField {
            let value = NSNumber(value: isOn)
            obj?.setValue(value, forKey: valueField)
        }
    }
}
