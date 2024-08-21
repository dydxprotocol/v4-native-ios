//
//  KeyboardAdjustingViewController.swift
//  UIToolkits
//
//  Created by John Huang on 5/14/19.
//  Copyright © 2019 dYdX. All rights reserved.
//

import Utilities

open class KeyboardAdjustingViewController: UIViewController, KeyboardAdjustingProtocol {
    public var bottom: CGFloat?

    @IBOutlet public var bottomConstraint: NSLayoutConstraint?
    public var keyboardObserver: NotificationToken?
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if bottomConstraint != nil {
            registerKeyboardObserver()
        }
    }

    override open func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
//        keyboardObserver = nil
    }

    open func layout(notif: Notification, bottom: CGFloat?) {
        layout(notif: notif, bottom: bottom, completion: nil)
    }
}
