//
//  ListObjectPresenter.swift
//  PlatformParticles
//
//  Created by Qiang Huang on 9/3/21.
//  Copyright © 2021 dYdX. All rights reserved.
//

import ParticlesKit
import UIKit

@objc public class ListObjectViewPresenter: ObjectViewPresenter {
    @IBOutlet var listPresenter: ListPresenter? {
        didSet {
            didSetListPresenter(oldValue: oldValue)
        }
    }

    @objc public dynamic var list: ListInteractor? {
        return model as? ListInteractor
    }

    override public func didSetModel(oldValue: ModelObjectProtocol?) {
        super.didSetModel(oldValue: oldValue)
        listPresenter?.interactor = list
    }

    func didSetListPresenter(oldValue: ListPresenter?) {
        if listPresenter !== oldValue {
            listPresenter?.visible = true
            listPresenter?.interactor = list
        }
    }
}
