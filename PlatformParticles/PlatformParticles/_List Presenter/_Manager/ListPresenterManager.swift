//
//  ListPresenterManager.swift
//  PresenterLib
//
//  Created by John Huang on 10/12/18.
//  Copyright © 2019 dYdX. All rights reserved.
//

import ParticlesKit
import UIToolkits

@objc open class ListPresenterManager: NSObject, ListPresenterManagerProtocol {
    @IBOutlet public var view: UIView?
    private var _presenters: [ListPresenter]?
    @IBOutlet public var loadingPresenter: ListPresenter? {
        didSet {
            loadingPresenter?.interactor = listInteractor
        }
    }

    @IBOutlet open var presenters: [ListPresenter]? {
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

    @IBOutlet open var listInteractor: ListInteractor? {
        didSet {
            loadingPresenter?.interactor = listInteractor
            current?.interactor = list(for: current)
        }
    }

    @IBInspectable open var flat: Bool = false {
        didSet {
            if flat != oldValue {
                updateFlat()
            }
        }
    }
    
    @IBInspectable open var stacked: Bool = false {
        didSet {
            if stacked != oldValue {
                updateFlat()
            }
        }
    }

    @IBOutlet open var flatConstraints: [NSLayoutConstraint]? {
        didSet {
            updateFlat()
        }
    }
    
    @IBOutlet open var stackedConstraints: [NSLayoutConstraint]? {
        didSet {
            updateFlat()
        }
    }

    public var switching: Bool = false
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

    @objc open dynamic var current: ListPresenter? {
        didSet {
            if current != oldValue {
                animateSwitch(from: oldValue, to: current)
            }
        }
    }

    open func animateSwitch(from oldValue: ListPresenter?, to newValue: ListPresenter?) {
        if !switching {
            switching = true
            UIView.animate(view, type: .flip, direction: .left, duration: UIView.defaultAnimationDuration, animations: {
                self.set(listPresenter: oldValue, visible: false)
                self.set(listPresenter: newValue, visible: true)
                self.switching = false
                if self.current != newValue {
                    self.animateSwitch(from: newValue, to: self.current)
                }
            }, completion: nil)
        }
    }

    open func set(listPresenter: ListPresenter?, visible: Bool) {
        if let listPresenter = listPresenter, listPresenter.visible != visible {
            listPresenter.visible = visible
            if visible {
                listPresenter.interactor = list(for: listPresenter)
            }
        }
    }

    open func list(for presenter: ListPresenter?) -> ListInteractor? {
        return listInteractor
    }

    open func updateLayout() {
        if let presenters = presenters {
            for presenter in presenters {
                presenter.updateLayout()
            }
        }
    }

    open func updateFlat() {
        var horizontalPriority: Float = 749
        var veriticalPriority: Float = 749
        if flat {
            if stacked {
                veriticalPriority = 751
            } else {
                horizontalPriority = 751
            }
        }
        if let constraints = flatConstraints {
            for constraint in constraints {
                constraint.priority = UILayoutPriority(rawValue: horizontalPriority)
            }
        }
        if let constraints = stackedConstraints {
            for constraint in constraints {
                constraint.priority = UILayoutPriority(rawValue: veriticalPriority)
            }
        }
        if let presenters = presenters {
            for presenter in presenters {
                if flat {
                    set(listPresenter: presenter, visible: true)
                } else {
                    set(listPresenter: presenter, visible: presenter == current)
                }
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

    open func show(presenter: ListPresenter?) {
        if let presenter = presenter {
            if let index = presenters?.first(where: { (item) -> Bool in
                item === presenter
            }) {
                current = index
            }
        }
    }
}
