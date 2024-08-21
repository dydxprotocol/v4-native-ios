//
//  ThinlinePresenter.swift
//  PlatformParticles
//
//  Created by Qiang Huang on 11/6/20.
//  Copyright © 2020 dYdX. All rights reserved.
//

import ParticlesKit
import UIToolkits
import Utilities

public class ThinlinePresenter: ObjectPresenter {
    @IBOutlet var height: NSLayoutConstraint? {
        didSet {
            if height !== oldValue {
                let scale = UIScreen.main.scale
                height?.constant = 1.0 / scale
            }
        }
    }
}
