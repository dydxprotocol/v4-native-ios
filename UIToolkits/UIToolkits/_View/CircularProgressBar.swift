//
//  CircularProgressBar.swift
//  UIToolkits
//
//  Created by Qiang Huang on 9/20/21.
//  Copyright © 2021 dYdX. All rights reserved.
//

import Foundation
import UIKit

public class CircularProgressBar: CALayer {
    private var circularPath: UIBezierPath!
    public var innerTrackShapeLayer: CAShapeLayer!
    public var outerTrackShapeLayer: CAShapeLayer!
    private let rotateTransformation = CATransform3DMakeRotation(-.pi / 2, 0, 0, 1)
    public var isUsingAnimation: Bool!
    public var progress: CGFloat = 0 {
        didSet {
            innerTrackShapeLayer.strokeEnd = progress / 100
        }
    }

    public init(radius: CGFloat, position: CGPoint, innerTrackColor: UIColor, outerTrackColor: UIColor, lineWidth: CGFloat) {
        super.init()

        circularPath = UIBezierPath(arcCenter: .zero, radius: radius, startAngle: 0, endAngle: .pi * 2, clockwise: true)
        outerTrackShapeLayer = CAShapeLayer()
        outerTrackShapeLayer.path = circularPath.cgPath
        outerTrackShapeLayer.position = position
        outerTrackShapeLayer.strokeColor = outerTrackColor.cgColor
        outerTrackShapeLayer.fillColor = UIColor.clear.cgColor
        outerTrackShapeLayer.lineWidth = lineWidth
        outerTrackShapeLayer.strokeEnd = 1
        outerTrackShapeLayer.lineCap = CAShapeLayerLineCap.round
        outerTrackShapeLayer.transform = rotateTransformation
        addSublayer(outerTrackShapeLayer)

        innerTrackShapeLayer = CAShapeLayer()
        innerTrackShapeLayer.strokeColor = innerTrackColor.cgColor
        innerTrackShapeLayer.position = position
        innerTrackShapeLayer.strokeEnd = progress
        innerTrackShapeLayer.lineWidth = lineWidth
        innerTrackShapeLayer.lineCap = CAShapeLayerLineCap.round
        innerTrackShapeLayer.fillColor = UIColor.clear.cgColor
        innerTrackShapeLayer.path = circularPath.cgPath
        innerTrackShapeLayer.transform = rotateTransformation
        addSublayer(innerTrackShapeLayer)
    }

    override public init(layer: Any) {
        super.init(layer: layer)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
