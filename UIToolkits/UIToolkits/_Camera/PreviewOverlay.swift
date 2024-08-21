//
//  PreviewOverlay.swift
//  UIToolkits
//
//  Created by Qiang Huang on 7/11/20.
//  Copyright © 2020 dYdX. All rights reserved.
//

import Foundation

@objc open class PreviewOverlay: NSObject, OverlayProtocol {
    open func layer(rect: CGRect) -> CALayer? {
        if let path = path(rect: rect) {
            return layer(path: path)
        }
        return nil
    }

    open func path(rect: CGRect) -> UIBezierPath? {
        return nil
    }

    open func layer(path: UIBezierPath) -> CALayer {
        let layer = CAShapeLayer()
        layer.path = path.cgPath
        layer.fillRule = CAShapeLayerFillRule.evenOdd
        layer.fillColor = UIColor.black.cgColor
        layer.opacity = 0.5
        return layer
    }
}
