//
//  CompositeObjectPresenter.swift
//  PlatformParticles
//
//  Created by Qiang Huang on 10/23/20.
//  Copyright © 2020 dYdX. All rights reserved.
//

import ParticlesKit
import UIToolkits

@objc open class CompositeObjectPresenter: ObjectPresenter {
    @IBOutlet var childPresenters: [ObjectPresenter]? {
        didSet {
            changeComposition()
        }
    }

    @IBOutlet var view: UIView?

    override open func didSetModel(oldValue: ModelObjectProtocol?) {
        super.didSetModel(oldValue: oldValue)
        changeComposition()
    }

    public func changeComposition() {
        if let childPresenters = childPresenters {
            for childPresenter in childPresenters {
                childPresenter.model = model
            }
        }
    }
}
