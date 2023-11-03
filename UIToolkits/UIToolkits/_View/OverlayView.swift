//
//  OverlayView.swift
//  UIToolkits
//
//  Created by Qiang Huang on 7/26/20.
//  Copyright © 2020 dYdX. All rights reserved.
//

import UIKit
import Utilities

@objc public enum EOverlayType: Int {
    case none
    case rect
    case cycle
}

@objc open class OverlayView: UIView {
    @IBInspectable var intOverlayType: Int = 0 {
        didSet {
            if intOverlayType != oldValue {
                updateOverlay()
            }
        }
    }

    var overlayType: EOverlayType {
        get { return EOverlayType(rawValue: intOverlayType) ?? .none }
        set { intOverlayType = newValue.rawValue }
    }

    @IBInspectable public var overlayCorner: CGFloat = 0.0 {
        didSet {
            if overlayCorner != oldValue {
                updateOverlay()
            }
        }
    }

    @IBInspectable public var overlayColor: UIColor? {
        didSet {
            if overlayColor !== oldValue {
                updateOverlay()
            }
        }
    }

    open var overlay: CALayer? {
        didSet {
            if overlay !== oldValue {
                oldValue?.removeFromSuperlayer()
                if let overlay = overlay {
                    layer.addSublayer(overlay)
                }
            }
        }
    }

    private var updateOverlayDebouncer: Debouncer = Debouncer()

    open func updateOverlay() {
        if overlayColor != nil, overlayType != .none, overlayCorner != 0.0 {
            let handler = updateOverlayDebouncer.debounce()
            handler?.run({ [weak self] in
                if let self = self {
                    if let path = self.path() {
                        self.overlay = self.layer(path: path)
                    } else {
                        self.overlay = nil
                    }
                }
            }, delay: 0)
        }
    }

    open func layer(path: UIBezierPath) -> CALayer? {
        if let overlayColor = overlayColor {
            let layer = CAShapeLayer()
            layer.path = path.cgPath
            layer.fillRule = CAShapeLayerFillRule.evenOdd
            layer.fillColor = overlayColor.cgColor
            layer.opacity = 1.0
            return layer
        }
        return nil
    }

    open func path() -> UIBezierPath? {
        if let overlayPath = self.overlayPath() {
            let path = UIBezierPath(rect: bounds)
            path.append(overlayPath)
            return path
        }
        return nil
    }

    open func rectPath() -> UIBezierPath? {
        return UIBezierPath(roundedRect: bounds, cornerRadius: overlayCorner)
    }

    open func cyclePath() -> UIBezierPath? {
        let radius = min(bounds.width, bounds.height)
        let circle = CGRect(x: (bounds.width - radius) / 2.0, y: (bounds.height - radius) / 2.0, width: radius, height: radius)
        return UIBezierPath(ovalIn: circle)
    }

    open func overlayPath() -> UIBezierPath? {
        switch overlayType {
        case .rect:
            return rectPath()

        case .cycle:
            return cyclePath()

        default:
            return nil
        }
    }
}
