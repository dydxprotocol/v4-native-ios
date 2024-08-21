//
//  GridPresenterManager.swift
//  PlatformParticles
//
//  Created by Qiang Huang on 2/15/19.
//  Copyright © 2019 dYdX. All rights reserved.
//

import ParticlesKit
import UIToolkits

@objc open class GridPresenterManager: NSObject, GridPresenterManagerProtocol {
    @IBOutlet var view: UIView?
    private var _presenters: [GridPresenter]?
    @IBOutlet public var loadingPresenter: GridPresenter? {
        didSet {
            loadingPresenter?.interactor = gridInteractor
        }
    }

    @IBOutlet public var presenters: [GridPresenter]? {
        get {
            return _presenters
        }
        set {
            _presenters = newValue?.sorted(by: { (presenter1, presenter2) -> Bool in
                presenter1.sequence < presenter2.sequence
            })
            if let _presenters = _presenters {
                for presenter in _presenters {
                    presenter.visible = false
                }
            }
            if let count = _presenters?.count {
                index = (count > 0) ? 0 : nil
            } else {
                index = nil
            }
        }
    }

    @IBOutlet public var gridInteractor: GridInteractor? {
        didSet {
            loadingPresenter?.interactor = gridInteractor
            current?.interactor = gridInteractor
        }
    }

    private var switching: Bool = false
    public var index: NSNumber? {
        didSet {
            if index != oldValue {
                if let index = index {
                    current = presenters?[index.intValue]
                } else {
                    current = nil
                }
            }
        }
    }

    public var current: GridPresenter? {
        didSet {
            if current != oldValue {
                animateSwitch(from: oldValue, to: current)
            }
        }
    }

    public func animateSwitch(from oldValue: GridPresenter?, to newValue: GridPresenter?) {
        if !switching {
            switching = true
            UIView.animate(view, type: .flip, direction: .left, duration: UIView.defaultAnimationDuration, animations: {
                oldValue?.visible = false
                oldValue?.interactor = nil
                newValue?.visible = true
                newValue?.interactor = self.gridInteractor
                self.switching = false
                if self.current != newValue {
                    self.animateSwitch(from: newValue, to: self.current)
                }
            }, completion: nil)
        }
    }

    open func updateLayout() {
        if let presenters = presenters {
            for presenter in presenters {
                presenter.updateLayout()
            }
        }
    }

    open func show(view: String?) {
        if let view = view {
            if let index = presenters?.first(where: { (presenter) -> Bool in
                presenter.title == view
            }) {
                current = index
            }
        }
    }
}
