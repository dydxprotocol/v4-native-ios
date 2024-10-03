//
//  ObjectCompositeLinePresenter.swift
//  PlatformParticles
//
//  Created by Qiang Huang on 6/14/21.
//  Copyright © 2021 dYdX. All rights reserved.
//

import ParticlesKit

open class ObjectCompositeLinePresenter: ObjectLinePresenter {
    @objc open dynamic var compositeLine: ObjectCompositeLineInteractor? {
        return model as? ObjectCompositeLineInteractor
    }
    @IBOutlet var presenter1: ObjectValueLinePresenter?
    @IBOutlet var presenter2: ObjectValueLinePresenter?

    open override func didSetModel(oldValue: ModelObjectProtocol?) {
        super.didSetModel(oldValue: oldValue)
        presenter1?.model = compositeLine?.interactor1
        presenter2?.model = compositeLine?.interactor2
    }
}
