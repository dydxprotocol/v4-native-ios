//
//  ListObjectPresenter.swift
//  ParticlesKit
//
//  Created by Qiang Huang on 1/20/20.
//  Copyright © 2020 dYdX. All rights reserved.
//

import Foundation

open class ListObjectPresenter: ObjectPresenter {
    open override var model: ModelObjectProtocol? {
        didSet {
            listPresenter?.interactor = (model as? ListInteractor)
        }
    }

    @IBOutlet open var listPresenter: ListPresenter? {
        didSet {
            listPresenter?.visible = true
        }
    }

    open override var selectable: Bool {
        return false
    }
}
