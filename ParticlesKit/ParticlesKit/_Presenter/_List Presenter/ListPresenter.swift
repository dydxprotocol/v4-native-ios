//
//  ListPresenterProtocol.swift
//  PresenterLib
//
//  Created by John Huang on 10/9/18.
//  Copyright © 2019 dYdX. All rights reserved.
//

import RoutingKit
import Utilities

public enum PresenterMode: Int {
    case linear
    case sections
}

public typealias SelectionCallack = (_ deselect: Bool) -> Void

@IBDesignable
open class ListPresenter: NSObject {
    @IBInspectable open var sequence: Int = 0
    private var debouncer: Debouncer = Debouncer()
    @IBOutlet open dynamic var selectionHandler: SelectionHandlerProtocol? {
        didSet {
            changeObservation(from: oldValue, to: selectionHandler, keyPath: #keyPath(PersistSelectionHandlerProtocol.selected)) { [weak self] _, object, _, _ in
                if let self = self {
                    if (self.selectionHandler as? PersistSelectionHandlerProtocol)?.selected != nil || !(object is NSNull) {
                        if let handler = self.debouncer.debounce() {
                            handler.run({ [weak self] in
                                if let self = self {
                                    self.changed(selected: (self.selectionHandler as? PersistSelectionHandlerProtocol)?.selected)
                                }
                            }, delay: 0.01)
                        }
                    }
                }
            }
        }
    }

    open var moving: Bool = false

    @IBOutlet open dynamic var interactor: ListInteractor? {
        didSet {
            didSetInteractor(oldValue: oldValue)
        }
    }

    @IBInspectable open dynamic var visible: Bool = true {
        didSet {
            if visible != oldValue {
                if visible == true, !(pending?.containsSame(as: current) ?? false) {
                    update()
                }
            }
        }
    }

    open var count: Int? {
        return current?.count
    }

    open var title: String? {
        return nil
    }

    @objc open dynamic var items: [ModelObjectProtocol]? {
        didSet {
            let filtered = filter(items: items)
            pending = filtered
        }
    }

    @objc open dynamic var pending: [ModelObjectProtocol]? {
        didSet {
            pendingUpdate()
        }
    }

    @objc open dynamic var current: [ModelObjectProtocol]? {
        didSet {
            didSetCurrent(oldValue: oldValue)
        }
    }

    open func didSetInteractor(oldValue: ListInteractor?) {
        changeObservation(from: oldValue, to: interactor, keyPath: #keyPath(ListInteractor.list)) { [weak self] _, _, _, _ in
            if let self = self, !self.moving {
                self.items = self.interactor?.list
            }
        }
    }

    open func filter(items: [ModelObjectProtocol]?) -> [ModelObjectProtocol]? {
        return items
    }

    open func pendingUpdate() {
        if visible == true {
            update()
        }
    }

    open func update() {
        update(move: true)
    }

    open func update(move: Bool) {
    }

    open func firstIndex(of object: ModelObjectProtocol, in list: [ModelObjectProtocol], after start: Int) -> Int? {
        return list.suffix(from: start).firstIndex(where: { (item) -> Bool in
            object === item
        })
    }

    open func index(of object: ModelObjectProtocol?) -> Int? {
        if let object = object, let current = current {
            return firstIndex(of: object, in: current, after: 0)
        }
        return nil
    }

    open func select(index: Int, completion: SelectionCallack?) {
        select(object: object(at: index), completion: completion)
    }

    open func select(object: ModelObjectProtocol?, completion: SelectionCallack?) {
        let selection: SelectionHandlerProtocol = selectionHandler ?? SelectionHandler.standard
        let selected = selection.select(object)
        completion?(!selected)
    }

    open func deselect(index: Int) {
        deselect(object: object(at: index))
    }

    open func deselect(object: ModelObjectProtocol?) {
        let selection: SelectionHandlerProtocol = selectionHandler ?? SelectionHandler.standard
        selection.deselect(object)
    }

    open func object(at index: Int) -> ModelObjectProtocol? {
        return current?.at(index)
    }

    open func updateLayout() {
    }

    open func changed(selected: [ModelObjectProtocol]?) {
    }

    open func didSetCurrent(oldValue: [ModelObjectProtocol]?) {
    }
}

@objc public protocol ScrollingProtocol: NSObjectProtocol {
    @objc var autoScroll: Bool { get set }
    @objc var isAtEnd: Bool { get set }
    func scrollToEnd(animated: Bool)
}
