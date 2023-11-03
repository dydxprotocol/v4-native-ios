//
//  QRCode.swift
//  UIToolkits
//
//  Created by Qiang Huang on 6/1/20.
//  Copyright © 2020 dYdX. All rights reserved.
//

import UIKit

public class QRCode: NSObject {
    static public func generate(from string: String, width: Int) -> UIImage? {
        let data = string.data(using: String.Encoding.utf16)

        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            if let bitmap = filter.outputImage {
                let image = UIImage(ciImage: bitmap)
                let scale = max(width / Int(image.size.width), 1)

                let transform = CGAffineTransform(scaleX: CGFloat(scale), y: CGFloat(scale))
                let output = bitmap.transformed(by: transform)
                return UIImage(ciImage: output)
            }
        }

        return nil
    }
}
