//
//  DrawingView.swift
//  UIToolkits
//
//  Created by Qiang Huang on 1/14/20.
//  Copyright © 2020 dYdX. All rights reserved.
//

import UIKit
import Utilities

open class DrawingView: UIView {
    @IBInspectable public var lineColor: UIColor = UIColor.black
    @IBInspectable public var lineWidth: CGFloat = 4.0

    @objc public dynamic var path: UIBezierPath? {
        didSet {
            if path !== oldValue {
                drawingLayer = buildDrawingLayer(path: path)
            }
        }
    }

    private var drawingLayer: CAShapeLayer? {
        didSet {
            if drawingLayer !== oldValue {
                oldValue?.removeFromSuperlayer()
                if let drawingLayer = drawingLayer {
                    layer.addSublayer(drawingLayer)
                }
                setNeedsDisplay()
            }
        }
    }

    @objc public dynamic var points: [CGPoint]?

    private var last: CGPoint? {
        didSet {
            if last != oldValue {
                if let last = last {
                    if points == nil {
                        points = []
                    }
                    points?.append(last)
                    if let previous = oldValue {
                        if let path = path {
                            path.addLine(to: last)
                            setNeedsDisplay()
                        } else {
                            let path = UIBezierPath()
                            path.move(to: previous)
                            path.addLine(to: last)
                            self.path = path
                        }
                    }
                } else {
                    path = nil
                    points = nil
                }
            }
        }
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupDrawing()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupDrawing()
    }

    open override func awakeFromNib() {
        super.awakeFromNib()
        setupDrawing()
    }

    open func setupDrawing() {
        clipsToBounds = true
        isMultipleTouchEnabled = false
    }

    open override func draw(_ rect: CGRect) {
        super.draw(rect)
        path?.stroke()
    }

    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = event?.allTouches?.first {
            last = touch.location(in: self)
        }
    }

    open override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = event?.allTouches?.first {
            last = touch.location(in: self)
        }
    }

    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = event?.allTouches?.first {
            last = touch.location(in: self)
            end()
        }
    }

    open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        last = nil
    }

    private func buildDrawingLayer(path: UIBezierPath?) -> CAShapeLayer? {
        if let path = path {
            let layer = CAShapeLayer()
            layer.path = path.cgPath
            layer.strokeColor = lineColor.cgColor
            layer.lineWidth = lineWidth
            layer.fillColor = UIColor.clear.cgColor
            path.lineWidth = lineWidth
            Console.shared.log("line width: \(lineWidth)")
            return layer
        } else {
            return nil
        }
    }

    private func end() {
        last = nil
    }
}
