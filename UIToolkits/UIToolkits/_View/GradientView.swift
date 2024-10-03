//
//  GradientView.swift
//  UIToolkits
//
//  Created by Mike Maguire on 9/20/24.
//  Copyright © 2024 dYdX. All rights reserved.
//

import UIKit

public class GradientView: UIView {

    // Configurable properties
    public var gradientColors: [UIColor] {
        didSet {
            gradientLayer.colors = gradientColors.map { $0.cgColor }
        }
    }
    private let startPoint: CGPoint
    private let endPoint: CGPoint
    private let gradientLayer = CAGradientLayer()

    // Initializers
    public init(gradientColors: [UIColor],
         startPoint: CGPoint = CGPoint(x: 0.5, y: 0),
         endPoint: CGPoint = CGPoint(x: 0.5, y: 1)) {
        self.gradientColors = gradientColors
        self.startPoint = startPoint
        self.endPoint = endPoint
        super.init(frame: .zero)
        setupGradientLayer()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Setup gradient layer
    private func setupGradientLayer() {
        gradientLayer.colors = gradientColors.map { $0.cgColor }
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
        layer.insertSublayer(gradientLayer, at: 0)
    }

    // Adjust gradient layer's frame when the view's bounds change
    public override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }

    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            setupGradientLayer()
        }
    }
}
