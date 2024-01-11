//
//  UIColor+Hex.swift
//  Utilities
//
//  Created by Rui Huang on 8/9/22.
//  Copyright © 2022 dYdX Trading Inc. All rights reserved.
//

import Foundation

extension UIColor {
    public convenience init?(hex: String?) {
           let input: String! = (hex ?? "")
               .replacingOccurrences(of: "#", with: "")
               .uppercased()
           var alpha: CGFloat = 1.0
           var red: CGFloat = 0
           var blue: CGFloat = 0
           var green: CGFloat = 0
           switch (input.count) {
           case 3 /* #RGB */:
               red = Self.colorComponent(from: input, start: 0, length: 1)
               green = Self.colorComponent(from: input, start: 1, length: 1)
               blue = Self.colorComponent(from: input, start: 2, length: 1)
               break
           case 4 /* #ARGB */:
               alpha = Self.colorComponent(from: input, start: 0, length: 1)
               red = Self.colorComponent(from: input, start: 1, length: 1)
               green = Self.colorComponent(from: input, start: 2, length: 1)
               blue = Self.colorComponent(from: input, start: 3, length: 1)
               break
           case 6 /* #RRGGBB */:
               red = Self.colorComponent(from: input, start: 0, length: 2)
               green = Self.colorComponent(from: input, start: 2, length: 2)
               blue = Self.colorComponent(from: input, start: 4, length: 2)
               break
           case 8 /* #RRGGBBAA */:
               red = Self.colorComponent(from: input, start: 0, length: 2)
               green = Self.colorComponent(from: input, start: 2, length: 2)
               blue = Self.colorComponent(from: input, start: 4, length: 2)
               alpha = Self.colorComponent(from: input, start: 6, length: 2)
               break
           default:
               NSException.raise(NSExceptionName("Invalid color value"), format: "Color value \"%@\" is invalid.  It should be a hex value of the form #RBG, #ARGB, #RRGGBB, or #AARRGGBB", arguments:getVaList([hex ?? ""]))
           }
           self.init(red: red, green: green, blue: blue, alpha: alpha)
       }

    static func colorComponent(from string: String!, start: Int, length: Int) -> CGFloat {
            let substring = (string as NSString)
                .substring(with: NSRange(location: start, length: length))
            let fullHex = length == 2 ? substring : "\(substring)\(substring)"
            var hexComponent: UInt64 = 0
            Scanner(string: fullHex)
                .scanHexInt64(&hexComponent)
            return CGFloat(Double(hexComponent) / 255.0)
        }
}

extension UIColor {
    public static func color(string: String?) -> UIColor? {
        if let string = string {
            let hash = abs(string.sdbmhash)
            let colorNum = hash % (256 * 256 * 256)
            let red = colorNum >> 16
            let green = (colorNum & 0x00FF00) >> 8
            let blue = (colorNum & 0x0000FF)
            let darkeningFactor = CGFloat(1.25 * 255.0)
            return UIColor(red: CGFloat(red) / darkeningFactor, green: CGFloat(green) / darkeningFactor, blue: CGFloat(blue) / darkeningFactor, alpha: 1.0)
        }
        return nil
    }

    public static func blend(color1: UIColor, intensity1: CGFloat = 0.5, color2: UIColor, intensity2: CGFloat = 0.5) -> UIColor {
        let total = intensity1 + intensity2
        let l1 = intensity1/total
        let l2 = intensity2/total
        guard l1 > 0 else { return color2}
        guard l2 > 0 else { return color1}
        var (r1, g1, b1, a1): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
        var (r2, g2, b2, a2): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)

        color1.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        color2.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)

        return UIColor(red: l1*r1 + l2*r2, green: l1*g1 + l2*g2, blue: l1*b1 + l2*b2, alpha: l1*a1 + l2*a2)
    }
}
