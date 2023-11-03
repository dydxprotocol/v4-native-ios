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

    @objc open func dragToDismiss() -> Bool {
        return true
    }

    @objc open func supportsLongForm() -> Bool {
        return UIResponder.current is UITextField
    }
}

@objc public protocol LayoutUpdateProtocol: NSObjectProtocol {
    func layoutChanged()
    func expand(fullScreen: Bool)
}

extension UIViewController: PanModalPresentable {
    public var panScrollable: UIScrollView? {
        return scrollable
    }

    public var longFormHeight: PanModalHeight {
        return .maxHeightWithTopInset(20)
    }

    public var shortFormHeight: PanModalHeight {
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

    @objc open var allowsDragToDismiss: Bool {
        return dragToDismiss()
    }

    public func shouldTransition(to state: PanModalPresentationController.PresentationState) -> Bool {
        switch state {
        case .shortForm:
            return true

        case .longForm:
            return supportsLongForm()
        }
    }

    public func panLayout(to state: PanModalPresentationController.PresentationState?) {
        panModalSetNeedsLayoutUpdate()
        if let state = state {
            panModalTransition(to: state)
        }
    }
    
    @objc open func panModalWillDismiss() {
    }

    @objc open func panModalDidDismiss() {
    }
}

extension UIViewController: LayoutUpdateProtocol {
    open func layoutChanged() {
        if UIResponder.current is UITextField {
        } else {
            panLayout(to: .shortForm)
        }
    }

    open func expand(fullScreen: Bool) {
        panLayout(to: fullScreen ? .longForm : .shortForm)
    }
}
