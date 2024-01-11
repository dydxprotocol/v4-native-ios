//
//  GradientView.swift
//  UIToolkits
//
//  Created by Qiang Huang on 9/6/21.
//  Copyright © 2021 dYdX. All rights reserved.
//

import UIKit

@objc public class GradientView: UIView {
    override open class var layerClass: AnyClass {
       return CAGradientLayer.classForCoder()
    }
    @IBInspectable var startColor: UIColor?
    @IBInspectable var endColor: UIColor?

    private var gradientLayer: CAGradientLayer? {
        return layer as? CAGradientLayer
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public override func awakeFromNib() {
        super.awakeFromNib()
        gradientLayer?.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer?.endPoint = CGPoint(x: 1.0, y: 0.5)
        setupLayer()
    }

    public func set(startColor: UIColor?, endColor: UIColor?) {
        self.startColor = startColor
        self.endColor = endColor
        setupLayer()
    }

    private func setupLayer() {
        if let startColor = startColor, let endColor = endColor {
            gradientLayer?.colors = [startColor.cgColor, endColor.cgColor]
        } else {
            gradientLayer?.colors = nil
        }
    }
}
