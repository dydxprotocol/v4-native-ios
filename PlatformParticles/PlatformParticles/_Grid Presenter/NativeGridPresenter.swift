//
//  NativeGridPresenter.swift
//  PlatformParticles
//
//  Created by Qiang Huang on 1/27/19.
//  Copyright © 2019 dYdX. All rights reserved.
//

import ParticlesKit
import UIToolkits

open class NativeGridPresenter: GridPresenter {
    @IBOutlet open var view: ViewProtocol? {
        didSet {
            updateVisibility()
        }
    }

    open override var visible: Bool? {
        didSet {
            updateVisibility()
        }
    }

    open func updateVisibility() {
        view?.visible = visible ?? false
    }
}
