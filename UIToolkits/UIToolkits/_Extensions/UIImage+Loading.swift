//
//  UIImage+Loading.swift
//  UIToolkits
//
//  Created by Qiang Huang on 7/21/20.
//  Copyright © 2020 dYdX. All rights reserved.
//

import UIKit

public extension UIImage {
    static func named(_ name: String, bundles: [Bundle]) -> UIImage? {
        var image: UIImage?
        for bundle in bundles {
            image = UIImage(named: name, in: bundle, compatibleWith: nil)
            if image != nil {
                break
            }
        }
        return image
    }

    func normalized() -> UIImage {
        autoreleasepool {
            if imageOrientation == UIImage.Orientation.up {
                return self
            }

            UIGraphicsBeginImageContextWithOptions(size, false, scale)
            let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            draw(in: rect)

            if let normalizedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext() {
                UIGraphicsEndImageContext()
                return normalizedImage
            } else {
                UIGraphicsEndImageContext()
                return self
            }
        }
    }
}
