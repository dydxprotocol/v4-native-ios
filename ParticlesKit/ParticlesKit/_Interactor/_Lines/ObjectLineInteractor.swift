//
//  ObjectLineInteractor.swift
//  ParticlesKit
//
//  Created by Qiang Huang on 6/10/21.
//  Copyright © 2021 dYdX. All rights reserved.
//

import Utilities

@objc open class ObjectLineInteractor: BaseInteractor, InteractorProtocol, XibProviderProtocol {
    @IBInspectable open dynamic var title: String?
    @IBInspectable open dynamic var xib: String?

    @objc public dynamic var formatter: ValueFormatterProtocol?

    @objc open dynamic var entity: ModelObjectProtocol? {
        didSet {
            didSetEntity(oldValue: oldValue)
        }
    }

    open func didSetEntity(oldValue: ModelObjectProtocol?) {
    }
}
