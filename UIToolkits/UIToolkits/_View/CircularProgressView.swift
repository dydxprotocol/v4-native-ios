//
//  CircularProgressView.swift
//  UIToolkits
//
//  Created by Qiang Huang on 9/21/21.
//  Copyright © 2021 dYdX. All rights reserved.
//

import UIKit
import Utilities

@objc public class CircularProgressView: UIView {
    public var progressLayer: CircularProgressBar? {
        didSet {
            if progressLayer !== oldValue {
                oldValue?.removeFromSuperlayer()
                if let progressLayer = progressLayer {
                    layer.addSublayer(progressLayer)
                }
            }
        }
    }

    public var size: CGSize?
    
    @IBInspectable public var radius: CGFloat = 10.0
    @IBInspectable public var lineWidth: CGFloat = 2.0
    @IBInspectable public var innerTrackColor: UIColor? = nil {
        didSet {
            if innerTrackColor !== oldValue {
                progressLayer?.innerTrackShapeLayer.strokeColor = innerTrackColor?.cgColor
            }
        }
    }

    @IBInspectable public var outerTrackColor: UIColor? = nil {
        didSet {
            if outerTrackColor !== oldValue {
                progressLayer?.outerTrackShapeLayer.strokeColor = outerTrackColor?.cgColor
            }
        }
    }

    private var drawingDebouncer = Debouncer()

    public var progress: CGFloat = 0.0 {
        didSet {
            drawProgress()
        }
    }

    override open func awakeFromNib() {
        super.awakeFromNib()
        redrawSelf()
    }

    public override var bounds: CGRect {
        didSet {
            redrawSelf()
        }
    }
    
    public func redraw() {
        drawingDebouncer.debounce()?.run({ [weak self] in
            self?.redrawSelf()
        }, delay: 0.05)
    }

    private func redrawSelf() {
        let width = size?.width ?? bounds.width
        let height = size?.height ?? bounds.height
        let xPosition = width / 2.0
        let yPosition = height / 2.0
        let position = CGPoint(x: xPosition, y: yPosition)
        progressLayer = CircularProgressBar(radius: min(width, height) / 2.0, position: position, innerTrackColor: innerTrackColor ?? UIColor.label, outerTrackColor: outerTrackColor ?? UIColor.systemBackground, lineWidth: lineWidth)
        drawProgress()
    }

    private func drawProgress() {
        if progress > 1.0 {
            progressLayer?.progress = 100.0
        } else if progress < 0.0 {
            progressLayer?.progress = 0.0
        } else {
            progressLayer?.progress = progress * 100.0
        }
    }
}
