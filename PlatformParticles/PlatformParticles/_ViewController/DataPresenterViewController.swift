//
//  DataPresenterViewController.swift
//  PresenterLib
//
//  Created by Qiang Huang on 11/21/18.
//  Copyright © 2018 dYdX. All rights reserved.
//

import ParticlesKit

open class DataPresenterViewController: ListPresenterViewController {
    @IBOutlet open var interactor: InteractorProtocol? {
        didSet {
            changeObservation(from: oldValue, to: interactor, keyPath: #keyPath(InteractorProtocol.entity), block: { [weak self] _, _, _, _ in
                if let self = self {
                    self.entity = self.interactor?.entity
                }
            })
        }
    }

    open var entity: ModelObjectProtocol?
}
