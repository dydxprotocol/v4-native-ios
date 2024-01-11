//
//  ObjectLinePresenter.swift
//  PlatformParticles
//
//  Created by Qiang Huang on 6/10/21.
//  Copyright © 2021 dYdX. All rights reserved.
//

import ParticlesKit

@objc open class ObjectLinePresenter: ObjectViewPresenter {
    @IBOutlet var titleLabel: UILabel?

    public var line: ObjectLineInteractor? {
        return model as? ObjectLineInteractor
    }

    @objc open dynamic var title: String? {
        didSet {
            didSetTitle(oldValue: oldValue)
        }
    }

    @objc open dynamic var formatter: ValueFormatterProtocol? {
        didSet {
            didSetFormatter(oldValue: oldValue)
        }
    }

    open override func didSetModel(oldValue: ModelObjectProtocol?) {
        super.didSetModel(oldValue: oldValue)
        changeObservation(from: oldValue, to: line, keyPath: #keyPath(ObjectLineInteractor.title)) { [weak self] _, _, _, _ in
            self?.title = self?.line?.title
        }
        changeObservation(from: oldValue, to: line, keyPath: #keyPath(ObjectLineInteractor.formatter)) { [weak self] _, _, _, _ in
            self?.formatter = self?.line?.formatter
        }
    }

    open func didSetTitle(oldValue: String?) {
        titleLabel?.text = title
    }

    open func didSetFormatter(oldValue: ValueFormatterProtocol?) {
    }
}
