//
//  ListInteractorPresenterView.swift
//  PlatformParticles
//
//  Created by Qiang Huang on 1/1/19.
//  Copyright © 2019 dYdX. All rights reserved.
//

import ParticlesKit
import UIKit

@objc public class ListInteractorPresenterView: UIView, ObjectPresenterProtocol {
    @IBOutlet public var presenter: ListPresenter? {
        didSet {
            if presenter !== oldValue {
                presenter?.visible = true
            }
        }
    }

    public var model: ModelObjectProtocol? {
        didSet {
            if model !== oldValue {
                presenter?.interactor = interactor
            }
        }
    }

    public var interactor: ListInteractor? {
        return model as? ListInteractor
    }

    @objc open var selectable: Bool {
        return false
    }
}
