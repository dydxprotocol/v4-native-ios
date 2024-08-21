//
//  UIImage+Tint.swift
//  UIToolkits
//
//  Created by Qiang Huang on 1/19/20.
//  Copyright © 2020 dYdX. All rights reserved.
//

import UIKit

public extension UIImage {
    static func load(file: String?) -> UIImage? {
        if let file = file, let data = NSData(contentsOfFile: file) {
            return UIImage(data: data as Data)
        }
        return nil
    }

    func tint(color: UIColor?) -> UIImage? {
        if let color = color, let maskImage = cgImage {
            let width = size.width
            let height = size.height
            let bounds = CGRect(x: 0, y: 0, width: width, height: height)

            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
            let context = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)!

            context.clip(to: bounds, mask: maskImage)
            context.setFillColor(color.cgColor)
            context.fill(bounds)

            if let cgImage = context.makeImage() {
                let coloredImage = UIImage(cgImage: cgImage)
                return coloredImage
            }
        }
        return self
    }

    func resize(to targetSize: CGSize) -> UIImage? {
        autoreleasepool {
            let size = self.size

            let widthRatio = targetSize.width / size.width
            let heightRatio = targetSize.height / size.height

            // Figure out what our orientation is, and use that to form the rectangle
            var newSize: CGSize
            if widthRatio > heightRatio {
                newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
            } else {
                newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
            }

            // This is the rect that we've calculated out and this is what is actually used below
            let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

            // Actually do the resizing to the rect using the ImageContext stuff
            UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
            draw(in: rect)
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            return newImage
        }
    }

    func resizeProportional(to targetSize: CGSize) -> UIImage? {
        var calculated = CGSize()
        if size.width > size.height {
            calculated = CGSize(width: size.width / size.height * targetSize.height, height: targetSize.height)
        } else {
            calculated = CGSize(width: targetSize.width, height: size.height / size.width * targetSize.width)
        }
        return resize(to: calculated)
    }

    func resize(to targetSize: CGSize, leftPercentage: CGFloat, rightPercentage: CGFloat) -> UIImage? {
        autoreleasepool {
            UIGraphicsBeginImageContextWithOptions(targetSize, false, 1.0)
            let left = targetSize.width * leftPercentage
            let right = targetSize.width * rightPercentage
            let rect = CGRect(x: left * -1, y: 0, width: targetSize.width + left + right, height: targetSize.height)
            let myRect = CGRect(x: 0, y: 0, width: targetSize.width, height: targetSize.height)
            UIBezierPath(roundedRect: myRect, cornerRadius: targetSize.height / 2).addClip()
            draw(in: rect)
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return newImage
        }
    }
}
