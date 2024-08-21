//
//  UIView+Hierarchy.swift
//  UIToolkits
//
//  Created by John Huang on 1/17/19.
//  Copyright © 2019 dYdX. All rights reserved.
//

import SnapKit
import UIKit

extension UIView {
    public func parent<T: UIView>() -> T? {
        if let superview = superview as? T {
            return superview
        } else {
            let view: T? = superview?.parent()
            return view
        }
    }

    public func subview<T: UIView>() -> T? {
        if let subview: T = subviews.first(where: { (view) -> Bool in
            view is T
        }) as? T {
            return subview
        } else {
            var found: T?
            _ = subviews.first { (subview) -> Bool in
                found = subview.subview()
                return found != nil
            }
            return found
        }
    }

    public func viewController() -> UIViewController? {
        var responder: UIResponder? = self
        while responder != nil && !(responder is UIViewController) {
            responder = responder?.next
        }
        return responder as? UIViewController
    }

    public func bringToFront() {
        superview?.bringSubviewToFront(self)
    }

    @objc open func install(view: UIView, into contentView: UIView) {
        if contentView.bounds.size.width == 0.0 && contentView.bounds.size.height == 0.0 {
            contentView.bounds = view.bounds
        } else {
            view.frame = contentView.bounds
        }
        contentView.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.snp.updateConstraints() { make in
            make.edges.equalToSuperview()
        }
        contentView.sendSubviewToBack(view)
    }
}
