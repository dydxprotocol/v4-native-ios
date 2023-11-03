//
//  ImageFactory.swift
//  dydxViews
//
//  Created by Rui Huang on 4/27/23.
//

import Foundation
import UIKit
import PlatformUI
import Utilities
import UIToolkits

struct ImageFactory: SingletonProtocol {
    static var shared = ImageFactory()

    static func reload() {
        shared = ImageFactory()
    }

    lazy var sliderThumb: UIImage? = {
        let size = 32.0
        UIGraphicsBeginImageContextWithOptions(CGSize(width: size, height: size), false, 0)
        if let ctx = UIGraphicsGetCurrentContext() {
            ctx.saveGState()

             let cgColor = ThemeColor.SemanticColor.layer6.uiColor.cgColor
             var rect = CGRect(x: 0, y: 0, width: size, height: size)
             ctx.setFillColor(cgColor)
             ctx.fillEllipse(in: rect)

            rect = CGRect(x: size / 4, y: size / 4, width: size / 2, height: size / 2)
            ctx.setFillColor(cgColor)
            ctx.fillEllipse(in: rect)

            ctx.restoreGState()
        }

        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img
    }()

    lazy var sliderLine: UIImage? = {
        let startColor = RGBA(uiColor: ThemeSettings.negativeColor.uiColor)
        let midColor = RGBA(uiColor: ThemeColor.SemanticColor.layer2.uiColor)
        let endColor = RGBA(uiColor: ThemeSettings.positiveColor.uiColor)
        return UIImage.image(withRGBAGradientPoints: [.init(location: 0, color: startColor),
                                                      .init(location: 0.5, color: midColor),
                                                      .init(location: 1, color: endColor)],
                             size: CGSize(width: 180, height: 8))
    }()
}
