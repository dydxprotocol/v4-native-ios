//
//  SpinImageView.swift
//  UIToolkits
//
//  Created by Qiang Huang on 11/6/21.
//  Copyright © 2021 dYdX Trading Inc. All rights reserved.
//

import UIKit

@objc public class SpinImageView: UIImageView {
    public var rotating: Bool = false {
        didSet {
            if rotating != oldValue {
                if rotating {
                    reallyRotating = true
                } else {
                }
            }
        }
    }

    private var reallyRotating: Bool = false {
        didSet {
            if reallyRotating != oldValue {
                if reallyRotating {
                    rotate()
                }
            }
        }
    }

    private var upsideDown: Bool = false {
        didSet {
            if upsideDown != oldValue {
                if upsideDown {
                    rotate()
                } else {
                    if rotating {
                        rotate()
                    } else {
                        reallyRotating = false
                    }
                }
            }
        }
    }

    func rotate() {
        let kAnimationDuration = 1.0
        UIView.animate(withDuration: kAnimationDuration, delay: 0, options: .curveLinear) { [weak self] in
            if let self = self {
                let radians = self.upsideDown ? Double.pi * 2.0 : Double.pi
                self.transform = CGAffineTransform(rotationAngle: radians)
            }
        } completion: { [weak self] _ in
            if let self = self {
                self.upsideDown = !self.upsideDown
            }
        }
    }
}
