//
//  GridObjectPresenter.swift
//  ParticlesKit
//
//  Created by Qiang Huang on 1/20/20.
//  Copyright © 2020 dYdX. All rights reserved.
//

import Foundation

open class GridObjectPresenter: ObjectPresenter {
    open override var model: ModelObjectProtocol? {
        didSet {
            gridPresenter?.interactor = (model as? GridInteractor)
        }
    }

    @IBOutlet public var gridPresenter: GridPresenter? {
        didSet {
            gridPresenter?.visible = true
        }
    }
}
