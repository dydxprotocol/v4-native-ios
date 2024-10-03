//
//  ModelSelectionProtocol.swift
//  PresenterLib
//
//  Created by John Huang on 11/20/18.
//  Copyright © 2019 dYdX. All rights reserved.
//

import Foundation
import RoutingKit

@objc public protocol SelectionHandlerProtocol: NSObjectProtocol {
    @discardableResult @objc func select(_ object: ModelObjectProtocol?) -> Bool
    @objc func deselect(_ object: ModelObjectProtocol?)
}

@objc public protocol PersistSelectionHandlerProtocol: SelectionHandlerProtocol {
    @objc var singleSelected: ModelObjectProtocol? { get }
    @objc var selected: [ModelObjectProtocol]? { get set }
    @objc var multipleSelection: Bool { get set }
}

@objc open class RoutingSelectionHandler: NSObject & SelectionHandlerProtocol {
    @discardableResult open func select(_ object: ModelObjectProtocol?) -> Bool {
        if let origintor = object as? RoutingOriginatorProtocol {
            Router.shared?.navigate(to: origintor, animated: true, completion: nil)
        }
        return false
    }

    public func deselect(_ object: ModelObjectProtocol?) {
    }
}

@objc open class IdleSelectionHandler: NSObject, PersistSelectionHandlerProtocol {
    @objc open dynamic var singleSelected: ModelObjectProtocol? {
        if multipleSelection {
            return nil
        } else {
            return selected?.first
        }
    }

    @objc open dynamic var selected: [ModelObjectProtocol]? {
        didSet {
            if !(selected?.containsSame(as: oldValue) ?? false) {
                if let previous = oldValue {
                    for object in previous {
                        (object as? SelectableProtocol)?.isSelected = false
                    }
                }
                if let selected = selected {
                    for object in selected {
                        (object as? SelectableProtocol)?.isSelected = true
                    }
                }
            }
        }
    }

    @IBInspectable open dynamic var multipleSelection: Bool = false {
        didSet {
            if multipleSelection != oldValue {
                selected = nil
            }
        }
    }

    @discardableResult open func select(_ object: ModelObjectProtocol?) -> Bool {
        if let object = object {
            if multipleSelection {
                if let selectable = object as? (SelectableProtocol & ModelObjectProtocol) {
                    if !selectable.isSelected {
                        select(selectable: selectable)
                        selected(object: object)
                    }
                } else {
                    if selected?.first === object && (selected?.count ?? 0) == 1 {
                    } else {
                        selected = [object]
                        selected(object: object)
                    }
                }
            } else {
                if selected?.first === object && (selected?.count ?? 0) == 1 {
                } else {
                    selected = [object]
                    selected(object: object)
                }
            }
            return true
        } else {
            if selected != nil {
                selected = nil
            }
            return false
        }
    }

    open func deselect(_ object: ModelObjectProtocol?) {
        if let object = object {
            if multipleSelection {
                if let selectable = object as? (SelectableProtocol & ModelObjectProtocol) {
                    if selectable.isSelected {
                        deselect(selectable: selectable)
                    }
                } else {
                    if selected?.first === object {
                        selected = nil
                    }
                }
            } else {
                if selected?.first === object {
                    selected = nil
                }
            }
        }
    }

    open func deselect(selectable: SelectableProtocol & ModelObjectProtocol) {
        if var selected = self.selected {
            selected.removeAll { (item) -> Bool in
                item === selectable
            }
            self.selected = selected
        }
    }

    open func select(selectable: SelectableProtocol & ModelObjectProtocol) {
        var selected = self.selected ?? [ModelObjectProtocol]()
        selected.append(selectable)
        self.selected = selected
    }

    open func selected(object: ModelObjectProtocol) {
    }
}

@objc public class PersistSelectionHandler: IdleSelectionHandler {
    public override func selected(object: ModelObjectProtocol) {
        if !multipleSelection {
            if let origintor = object as? RoutingOriginatorProtocol {
                Router.shared?.navigate(to: origintor, animated: true, completion: nil)
            }
        }
    }
}

@objc public class SelectionHandler: NSObject {
    @objc public static var standard: SelectionHandlerProtocol = {
        RoutingSelectionHandler()
    }()
}
