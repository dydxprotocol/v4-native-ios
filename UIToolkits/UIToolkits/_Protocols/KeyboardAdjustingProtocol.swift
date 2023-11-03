//
//  KeyboardAdjustingProtocol.swift
//  UIToolkits
//
//  Created by John Huang on 5/14/19.
//  Copyright © 2019 dYdX. All rights reserved.
//

import UIKit
import Utilities

public protocol KeyboardAdjustingProtocol: AnyObject {
    var bottom: CGFloat? { get set }
    var bottomConstraint: NSLayoutConstraint? { get set }
    var keyboardObserver: NotificationToken? { get set }

    func layout(notif: Notification, bottom: CGFloat?)
}

public extension KeyboardAdjustingProtocol where Self: UIViewController {
    func registerKeyboardObserver() {
        if keyboardObserver == nil {
            keyboardObserver = NotificationCenter.default.observe(notification: UIResponder.keyboardWillChangeFrameNotification, do: { [weak self] (notif: Notification) in
                self?.keyboardWillChangeFrame(notif: notif)
            })
        }
    }

    func keyboardWillChangeFrame(notif: Notification) {
        if let bottom = bottom {
            layout(notif: notif, bottom: bottom)
        } else {
            bottom = bottomConstraint?.constant
            layout(notif: notif, bottom: nil)
        }
    }

    func layout(notif: Notification, bottom: CGFloat?, completion: ((Bool) -> Void)?) {
        if let start = (notif.userInfo![UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue, let end = (notif.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue, let duration = notif.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as? Double, let curve = notif.userInfo![UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt {
            let startInFrame = view.convert(start, from: nil)
            bottomConstraint?.constant = startInFrame.origin.y - view.bounds.size.height
            view.layoutIfNeeded()

            if start.origin.y < end.origin.y, let bottom = bottom {
                bottomConstraint?.constant = bottom
            } else {
                let endInView = view.convert(end, from: nil)
                bottomConstraint?.constant = endInView.origin.y - view.bounds.size.height
            }

            UIView.animate(withDuration: duration, delay: 0, options: UIView.AnimationOptions(rawValue: curve), animations: { [weak self] in
                if let self = self {
                    self.view.layoutIfNeeded()
                    self.bringEditingToView()
                }
            }, completion: completion)
        }
    }

    func bringEditingToView() {
        if let textInput = UIResponder.current as? (UIView & UITextInput) {
            if let cell: UITableViewCell = textInput.parent(), let tableView: UITableView = cell.parent(), let indexPath = tableView.indexPath(for: cell) {
                tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
        }
    }
}
