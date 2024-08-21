//
//  ObjectPresenter.swift
//  PresenterLib
//
//  Created by Qiang Huang on 10/10/18.
//  Copyright © 2018 dYdX. All rights reserved.
//

import Utilities
import Combine

@objc public protocol ObjectPresenterProtocol {
    @objc var model: ModelObjectProtocol? { get set }
    @objc optional var selectable: Bool { get }
}

@objc public protocol SelectableProtocol {
    @objc var isSelected: Bool { get set }
}

@objc public protocol HighlightableProtocol {
    @objc var isHighlighted: Bool { get set }
}

@objc open class ObjectPresenter: NSObject, ObjectPresenterProtocol, CombineObserving {
    public var cancellableMap = [AnyKeyPath: AnyCancellable]()
    
    @IBOutlet @objc open dynamic var model: ModelObjectProtocol? {
        didSet {
            if model !== oldValue {
                didSetModel(oldValue: oldValue)
            }
        }
    }

//    public var debouncer: Debouncer = Debouncer()

    @objc open dynamic var isFirst: Bool = false
    @objc open dynamic var isLast: Bool = false

    @objc open dynamic var selectable: Bool {
        return true
    }

    open func didSetModel(oldValue: ModelObjectProtocol?) {
    }
}

@objc public protocol ObjectTableCellPresenterProtocol {
    var showDisclosure: Bool { get }
}
