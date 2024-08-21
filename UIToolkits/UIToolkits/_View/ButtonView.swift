//
//  ButtonView.swift
//  UIToolkits
//
//  Created by Qiang Huang on 7/20/21.
//  Copyright © 2021 dYdX. All rights reserved.
//

import UIKit

@objc open class ButtonView: UIView, ButtonProtocol {
    public func removeTarget() {
        button?.removeTarget()
    }

    public func addTarget(_ target: AnyObject?, action: Selector) {
        button?.addTarget(target, action: action)
    }

    public func add(target: AnyObject?, action: Selector, for controlEvents: UIControl.Event) {
        button?.add(target: target, action: action, for: controlEvents)
    }

    @objc public var buttonTitle: String? {
        get {
            return button?.buttonTitle
        }
        set {
            button?.buttonTitle = newValue
        }
    }

    @objc public var buttonImage: NativeImage? {
        get {
            return button?.buttonImage
        }
        set {
            button?.buttonImage = newValue
        }
    }

    @objc public var buttonChecked: Bool {
        get {
            return button?.buttonChecked ?? false
        }
        set {
            button?.buttonChecked = newValue
        }
    }

    @IBOutlet public var button: UIButton?
}
