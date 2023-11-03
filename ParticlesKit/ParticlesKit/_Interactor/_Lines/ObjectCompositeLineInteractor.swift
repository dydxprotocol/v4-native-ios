//
//  ObjectCompositeLineInteractor.swift
//  ParticlesKit
//
//  Created by Qiang Huang on 6/14/21.
//  Copyright © 2021 dYdX. All rights reserved.
//

import Utilities

@objc open class ObjectCompositeLineInteractor: ObjectLineInteractor {
    @objc open dynamic var lineValue1: Any?
    @objc open dynamic var lineValue2: Any?

    public var interactor1: ObjectLineInteractor? {
        didSet {
            didSetInteractor1(oldValue: oldValue)
        }
    }

    public var interactor2: ObjectLineInteractor? {
        didSet {
            didSetInteractor2(oldValue: oldValue)
        }
    }

    public static func interactor(entity: ModelObjectProtocol?, title: String?, interactor1: ObjectLineInteractor, interactor2: ObjectLineInteractor, xib: String? = nil) -> ObjectCompositeLineInteractor {
        let interactor = ObjectCompositeLineInteractor()
        interactor.title = title
        interactor.xib = xib
        interactor.entity = entity
        interactor.interactor1 = interactor1
        interactor.interactor2 = interactor2
        return interactor
    }

    open override func didSetEntity(oldValue: ModelObjectProtocol?) {
        interactor1?.entity = entity
        interactor2?.entity = entity
    }

    private func didSetInteractor1(oldValue: ObjectLineInteractor?) {
        interactor1?.entity = entity
        changeObservation(from: oldValue, to: interactor1, keyPath: #keyPath(ObjectValueLineInteractor.lineValue)) { [weak self] _, _, _, _ in
            self?.lineValue1 = (self?.interactor1 as? ObjectValueLineInteractor)?.lineValue
        }
    }

    private func didSetInteractor2(oldValue: ObjectLineInteractor?) {
        interactor2?.entity = entity
        changeObservation(from: oldValue, to: interactor2, keyPath: #keyPath(ObjectValueLineInteractor.lineValue)) { [weak self] _, _, _, _ in
            self?.lineValue2 = (self?.interactor2 as? ObjectValueLineInteractor)?.lineValue
        }
    }
}
