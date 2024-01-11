//
//  ObjectPresenterView.swift
//  PresenterLib
//
//  Created by John Huang on 10/10/18.
//  Copyright © 2019 dYdX. All rights reserved.
//

import ParticlesKit
import UIKit
import UIToolkits

open class ObjectPresenterView: UIView, ObjectPresenterProtocol, SelectableProtocol, HighlightableProtocol {
    @IBOutlet public var presenter: ObjectPresenter? {
        didSet {
            #if DEBUG
            accessibilityIdentifier = String(describing: presenter)
            #endif
        }
    }

    public var model: ModelObjectProtocol? {
        get { return presenter?.model }
        set { presenter?.model = newValue }
    }

    open var selectable: Bool {
        return presenter?.selectable ?? false
    }

    open var showDisclosure: Bool? {
        if let tableCellPresenter = presenter as? ObjectTableCellPresenterProtocol {
            return tableCellPresenter.showDisclosure
        }
        return nil
    }

    public var isSelected: Bool = false {
        didSet {
            if let selectable = (presenter as? SelectableProtocol) {
                selectable.isSelected = isSelected
            }
        }
    }

    public var isHighlighted: Bool = false {
        didSet {
            if let highlightable = (presenter as? HighlightableProtocol) {
                highlightable.isHighlighted = isHighlighted
            }
        }
    }

    public var isFirst: Bool = false {
        didSet {
            presenter?.isFirst = isFirst
        }
    }

    public var isLast: Bool = false {
        didSet {
            presenter?.isLast = isLast
        }
    }
}

extension ObjectPresenter {
    public func updateLayout(view: UIView?) {
        if let view = view, model != nil {
            if let collectionView: UICollectionView = view.parent() {
                view.layoutIfNeeded()
                DispatchQueue.main.async {
                    collectionView.collectionViewLayout.invalidateLayout()
                }
            } else if let tableView: UITableView = view.parent() {
                if let uxTableView = tableView as? UXTableView {
                    uxTableView.updateLayout()
                } else {
                    DispatchQueue.main.async {
                        tableView.beginUpdates()
                        tableView.endUpdates()
                    }
                }
            } else {
                view.layoutIfNeeded()
            }
        }
    }
}
