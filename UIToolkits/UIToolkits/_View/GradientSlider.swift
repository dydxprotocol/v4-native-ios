//
//  GradientSlider.swift
//  UIToolkits
//
//  Created by Qiang Huang on 10/15/21.
//  Copyright © 2021 dYdX Trading Inc. All rights reserved.
//

import UIKit
import Utilities

public class GradientSlider: UISlider {
    public var gradientImage: UIImage?

    private var appliedGradientImage: UIImage? {
        didSet {
            if let appliedGradientImage = appliedGradientImage {
                let cappedImage = appliedGradientImage.resizableImage(withCapInsets: .zero)
                setMinimumTrackImage(cappedImage, for: .normal)
                setMaximumTrackImage(cappedImage, for: .normal)
            } else {
                setMinimumTrackImage(nil, for: .normal)
                setMaximumTrackImage(nil, for: .normal)
            }
        }
    }

    public var leftPercentage: CGFloat = 0.0 {
        didSet {
            if leftPercentage != oldValue {
                calculateGradient()
            }
        }
    }

    public var rightPercentage: CGFloat = 0.0 {
        didSet {
            if rightPercentage != oldValue {
                calculateGradient()
            }
        }
    }

    private var trackSize: CGSize? {
        didSet {
            if trackSize != oldValue {
                calculateGradient()
            }
        }
    }

    private var gradientDebouncer = Debouncer()

    override public func trackRect(forBounds bounds: CGRect) -> CGRect {
        let result = super.trackRect(forBounds: bounds)
        let origin: CGFloat = 8.0
        let diff = origin - result.origin.x
        let modified = CGRect(x: origin, y: result.origin.y, width: result.size.width - diff * 2, height: result.size.height)
        trackSize = modified.size
        return modified
    }

    private func calculateGradient() {
        gradientDebouncer.debounce()?.run({ [weak self] in
            self?.reallyCalculateGradient()
        }, delay: 0.0)
    }

    private func reallyCalculateGradient() {
        if let trackSize = trackSize, trackSize.width > 0.0, trackSize.height > 0.0 {
            appliedGradientImage = gradientImage?.resize(to: trackSize, leftPercentage: leftPercentage, rightPercentage: rightPercentage)
        } else {
            appliedGradientImage = nil
        }
    }
}

extension UIImage {
    var isPortrait: Bool { size.height > size.width }
    var isLandscape: Bool { size.width > size.height }
    var breadth: CGFloat { min(size.width, size.height) }
    var breadthSize: CGSize { .init(width: breadth, height: breadth) }
    var breadthRect: CGRect { .init(origin: .zero, size: breadthSize) }
    func rounded(with color: UIColor, width: CGFloat) -> UIImage? {
        guard let cgImage = cgImage?.cropping(to: .init(origin: .init(x: isLandscape ? ((size.width - size.height) / 2).rounded(.down) : .zero, y: isPortrait ? ((size.height - size.width) / 2).rounded(.down) : .zero), size: breadthSize)) else { return nil }

        let bleed = breadthRect.insetBy(dx: -width, dy: -width)
        let format = imageRendererFormat
        format.opaque = false

        return UIGraphicsImageRenderer(size: bleed.size, format: format).image { context in
            UIBezierPath(ovalIn: .init(origin: .zero, size: bleed.size)).addClip()
            var strokeRect = breadthRect.insetBy(dx: -width / 2, dy: -width / 2)
            strokeRect.origin = .init(x: width / 2, y: width / 2)
            UIImage(cgImage: cgImage, scale: 1, orientation: imageOrientation)
                .draw(in: strokeRect.insetBy(dx: width / 2, dy: width / 2))
            context.cgContext.setStrokeColor(color.cgColor)
            let line: UIBezierPath = .init(ovalIn: strokeRect)
            line.lineWidth = width
            line.stroke()
        }
    }
}

extension UIImage {
    func imageWithInsets(insets: UIEdgeInsets) -> UIImage? {
        autoreleasepool {
            UIGraphicsBeginImageContextWithOptions(
                CGSize(width: size.width + insets.left + insets.right,
                       height: size.height + insets.top + insets.bottom), false, scale)
            _ = UIGraphicsGetCurrentContext()
            let origin = CGPoint(x: insets.left, y: insets.top)
            draw(at: origin)
            let imageWithInsets = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return imageWithInsets
        }
    }
}
