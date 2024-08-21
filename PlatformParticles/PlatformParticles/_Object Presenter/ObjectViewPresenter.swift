//
//  ObjectViewPresenter.swift
//  PlatformParticles
//
//  Created by Qiang Huang on 4/19/21.
//  Copyright © 2021 dYdX. All rights reserved.
//

import ParticlesKit
import Utilities
import Combine

open class ObjectViewPresenter: ObjectPresenter, HighlightableProtocol {
    
    @IBOutlet open var view: UIView?
    @IBInspectable public var automaticHighlight: Bool = false

    public var isHighlighted: Bool = false {
        didSet {
            didSetIsHighlighted(oldValue: oldValue)
        }
    }

    private var layoutDebouncer: Debouncer = Debouncer()

    public func addTap(view: UIView?, action: Selector) {
        if let view = view {
            let tap = UITapGestureRecognizer(target: self, action: action)
            view.addGestureRecognizer(tap)
        }
    }

    open func updateLayout(animated: Bool) {
        if animated {
            UIView.animate(withDuration: UIView.defaultAnimationDuration) { [weak self] in
                self?.view?.layoutIfNeeded()
            }
        } else {
            view?.layoutIfNeeded()
        }
    }

    open func didSetIsHighlighted(oldValue: Bool) {
        if isHighlighted != oldValue {
            if automaticHighlight {
                view?.alpha = isHighlighted ? 0.7 : 1.0
            }
        }
    }
}
