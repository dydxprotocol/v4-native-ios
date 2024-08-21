//
//  UIViewController+Half.swift
//  UIToolkits
//
//  Created by Qiang Huang on 8/16/19.
//  Copyright © 2019 dYdX. All rights reserved.
//

import FloatingPanel
import PanModal
import UIKit
import UIToolkits
import Utilities

@objc extension UIViewController: UIViewControllerHalfProtocol {
    private struct AssociatedKey {
        static var floatingManagerKey = "viewController.half.manager"
    }

    public var floatingParent: FloatingPanelController? {
        return (navigationController?.parent as? FloatingPanelController) ?? (parent as? FloatingPanelController)
    }

    public var _floatingManager: FloatingProtocol? {
        get {
            return associatedObject(base: self, key: &AssociatedKey.floatingManagerKey)
        }
        set {
            let oldValue = _floatingManager
            if oldValue !== newValue {
                retainObject(base: self, key: &AssociatedKey.floatingManagerKey, value: newValue)
            }
        }
    }

    public var floatingManager: FloatingProtocol? {
        get {
            if _floatingManager == nil {
                _floatingManager = FloatingManager(parent: self)
            }
            return _floatingManager
        }
        set {
            _floatingManager = newValue
        }
    }

    public func dismiss(_ viewController: UIViewController?, animated: Bool) {
        floatingManager?.dismiss(viewController, animated: animated)
    }
}

public extension UIViewController {
    func move(to position: FloatingPanelState) {
        floatingParent?.move(to: position, animated: true, completion: nil)
    }
}
