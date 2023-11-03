//
//  ObjectTextLinePresenter.swift
//  PlatformParticles
//
//  Created by Qiang Huang on 6/10/21.
//  Copyright © 2021 dYdX. All rights reserved.
//

import UIToolkits
import Utilities

open class ObjectTextLinePresenter: ObjectValueLinePresenter {
    @IBOutlet var textLabel: UILabel?

    override open func didSetLineValue(oldValue: Any?) {
        textLabel?.text = text
    }
}
