//
//  HalfFloatingManager.swift
//  UIToolkits
//
//  Created by Qiang Huang on 10/22/19.
//  Copyright © 2019 dYdX. All rights reserved.
//

import FloatingPanel
import UIToolkits
import Utilities

open class IntrinsicPanelLayout: FloatingPanelBottomLayout {
}

open class FloatingManager: NSObject, FloatingProtocol, FloatingPanelControllerDelegate {
    public weak var parent: UIViewController?

    @objc open var halved: UIViewController? {
        return half?.contentViewController
    }

    open var half: FloatingPanelController? {
        didSet {
            if half !== oldValue {
                if let oldValue = oldValue {
                    oldValue.removePanelFromParent(animated: true)
                }
                if let half = half, let parent = parent {
                    half.addPanel(toParent: parent)
                }
            }
        }
    }

    public init(parent: UIViewController?) {
        super.init()
        self.parent = parent
    }

    @objc open func half(_ viewController: UIViewController?, animated: Bool) {
        half(viewController, shadow: true, presentationStyle: .overFullScreen, animated: animated)
    }

    @objc open func half(_ viewController: UIViewController?, shadow: Bool, presentationStyle: UIModalPresentationStyle, animated: Bool) {
        let floater = FloatingPanelController()

        // Initialize FloatingPanelController and add the view
        floater.surfaceView.layer.cornerRadius = 6.0
        floater.surfaceView.layer.shadowOpacity = shadow ? 1 : 0
        if #available(iOS 13.0, *) {
            floater.surfaceView.backgroundColor = UIColor.systemBackground
        } else {
            // Fallback on earlier versions
        }
        floater.isRemovalInteractionEnabled = true
        floater.modalPresentationStyle = presentationStyle

        let backdropTapGesture = UITapGestureRecognizer(target: self, action: #selector(backdrop(tapGesture:)))
        floater.backdropView.addGestureRecognizer(backdropTapGesture)
        floater.delegate = self

        // Set a content view controller
        floater.set(contentViewController: viewController)

        half = floater
    }

    @objc open func backdrop(tapGesture: UITapGestureRecognizer) {
        half = nil
    }

    open func floatingPanel(_ vc: FloatingPanelController, layoutFor newCollection: UITraitCollection) -> FloatingPanelLayout {
        IntrinsicPanelLayout()
    }

    public func floatingPanelDidMove(_ vc: FloatingPanelController) {
        DispatchQueue.main.async {
            if let current = UIResponder.current, current is UITextInput {
                current.resignFirstResponder()
            }
        }
    }

    open func floatingPanel(_ vc: FloatingPanelController, shouldRecognizeSimultaneouslyWith gestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }

    open func floatingPanelDidRemove(_ vc: FloatingPanelController) {
        if vc == half {
            half = nil
        }
    }

    open func floatingPanelDidChangeState(_ vc: FloatingPanelController) {
    }

    open func floatingPanelDidEndAttracting(_ vc: FloatingPanelController) {
    }

    open func dismiss(_ viewController: UIViewController?, animated: Bool) {
        if viewController?.floatingParent == half {
            half = nil
        }
    }

    open func floatingPanelShouldBeginDragging(_ fpc: FloatingPanelController) -> Bool {
        true
    }
}
