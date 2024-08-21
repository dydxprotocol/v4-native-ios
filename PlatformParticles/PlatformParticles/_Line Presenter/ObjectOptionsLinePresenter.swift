//
//  ObjectOptionsLinePresenter.swift
//  PlatformParticles
//
//  Created by Qiang Huang on 6/11/21.
//  Copyright © 2021 dYdX. All rights reserved.
//

import ParticlesKit
import UIToolkits
import Utilities

open class ObjectOptionsLinePresenter: ObjectValueLinePresenter {
    private var optionsInteractor: ObjectOptionsLineInteractor? {
        return valueLine as? ObjectOptionsLineInteractor
    }

    @IBOutlet var selector: UISegmentedControl? {
        didSet {
            if selector !== oldValue {
                oldValue?.removeTarget()
                populateSelector()
                selector?.add(target: self, action: #selector(option(_:)), for: UIControl.Event.valueChanged)
            }
        }
    }

    open override func didSetModel(oldValue: ModelObjectProtocol?) {
        super.didSetModel(oldValue: oldValue)
        changeObservation(from: oldValue, to: optionsInteractor, keyPath: "strings") { [weak self] _, _, _, _ in
            self?.populateSelector()
        }
    }

    private func populateSelector() {
        selector?.removeAllSegments()
        if let selector = selector, let strings = optionsInteractor?.strings {
            for string in strings {
                selector.insertSegment(withTitle: string, at: selector.numberOfSegments, animated: false)
            }
        }
        didSetLineValue(oldValue: nil)
    }

    override open func didSetLineValue(oldValue: Any?) {
        if let index = optionsInteractor?.selectionIndex, selector?.selectedIndex != index {
            selector?.selectedIndex = index
        }
    }

    @IBAction func option(_ sender: Any?) {
        optionsInteractor?.selectionIndex = selector?.selectedIndex
    }
}
