//
//  GridPresenter.swift
//  ParticlesKit
//
//  Created by Qiang Huang on 1/16/19.
//  Copyright © 2019 dYdX. All rights reserved.
//

import Foundation
import RoutingKit

@IBDesignable
@objc open class GridPresenter: NSObject {
    @IBInspectable open var sequence: Int = 0

    @IBOutlet open var selectionHandler: SelectionHandlerProtocol?

    @IBOutlet open dynamic var interactor: ModelGridProtocol? {
        didSet {
            if interactor !== oldValue {
                let grid = #keyPath(GridInteractor.grid)
                kvoController.unobserve(oldValue, keyPath: grid)
                if interactor != nil {
                    visible = true
                    changeObservation(from: oldValue, to: interactor, keyPath: grid) { [weak self] _, _, change, _ in
                        if let self = self {
                            let new = change[NSKeyValueChangeKey.newKey.rawValue] as? [[ModelObjectProtocol]]
                            if let current = self.current, let new = new {
                                if current.count > 0 && new.count > 0 {
                                    self.change(to: new)
                                } else {
                                    self.refresh(with: new)
                                }
                            } else {
                                self.refresh(with: new)
                            }
                        }
                    }
                } else {
                    refresh(with: nil)
                    visible = false
                }
            }
        }
    }

    @objc open dynamic var updating: Bool = false

    open var visible: Bool?

    open var count: Int? {
        return current?.count
    }

    open var title: String? {
        return nil
    }

    open var lastVisible: Int? {
        return nil
    }

    open var current: [[ModelObjectProtocol]]?

    open func change(to new: [[ModelObjectProtocol]]) {
        refresh(with: new)
    }

    open func refresh(with new: [[ModelObjectProtocol]]?) {
        current = new
        refresh(animated: true)
    }

    open func refresh(animated: Bool) {
    }

    open func select(x: Int, y: Int) {
        select(object: object(x: x, y: y))
    }

    open func select(object: ModelObjectProtocol?) {
        let selection: SelectionHandlerProtocol = selectionHandler ?? SelectionHandler.standard
        selection.select(object)
    }

    open func object(x: Int, y: Int) -> ModelObjectProtocol? {
        return current?[y][x]
    }

    open func updateLayout() {
    }
}
