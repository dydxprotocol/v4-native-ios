//
//  UIViewController+Embed.swift
//  UIToolkits
//
//  Created by Qiang Huang on 9/12/19.
//  Copyright © 2019 dYdX. All rights reserved.
//

import PanModal
import UIKit

extension UIViewController {
    @objc open var intrinsicHeight: NSNumber? {
        return nil
    }

    public func embed(_ viewController: UIViewController?, in view: UIView?) {
        if let viewController = viewController, let view = view {
            viewController.willMove(toParent: self)
//            viewController.view.frame = view.bounds
//            view.addSubview(viewController.view)
            view.install(view: viewController.view, into: view)
            addChild(viewController)
            viewController.didMove(toParent: self)
        }
    }

    public func remove(_ viewController: UIViewController?) {
        if let viewController = viewController {
            viewController.willMove(toParent: nil)
            viewController.view.removeFromSuperview()
            viewController.removeFromParent()
        }
    }
}

extension UIViewController: PanModalPresentable {
    public var panScrollable: UIScrollView? {
        return scrollable
    }

    public var longFormHeight: PanModalHeight {
        return panScrollable == nil ? .intrinsicHeight : .maxHeightWithTopInset(20)
    }

    @objc open var cornerRadius: CGFloat {
        return 36.0
    }

    @objc open var scrollable: UIScrollView? {
        return nil
    }

    @objc open var showDragIndicator: Bool {
        return false
    }
    
    @objc open func panModalDidDismiss() {
        
    }
}
