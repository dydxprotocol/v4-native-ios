//
//  UIGestureRecognizer+Closure.swift
//  UIToolkits
//
//  Created by Qiang Huang on 12/9/21.
//  Copyright © 2021 dYdX Trading Inc. All rights reserved.
//

import Utilities

extension UIGestureRecognizer {
    public typealias Action = ((UIGestureRecognizer) -> Void)

    private struct Keys {
        static var actionKey = "ActionKey"
    }

    private var block: Action? {
        get {
            return associatedObject(base: self, key: &Keys.actionKey)
        }
        set {
            retainObject(base: self, key: &Keys.actionKey, value: newValue)
        }
    }

    @objc func handleAction(recognizer: UIGestureRecognizer) {
        block?(recognizer)
    }

    public convenience init(block: @escaping ((UIGestureRecognizer) -> Void)) {
        self.init()
        self.block = block
        addTarget(self, action: #selector(handleAction(recognizer:)))
    }
}
