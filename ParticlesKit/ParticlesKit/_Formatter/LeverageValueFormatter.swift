//
//  PercentValueFormatter.swift
//  ParticlesKit
//
//  Created by Qiang Huang on 6/10/21.
//  Copyright © 2021 dYdX. All rights reserved.
//

import Utilities

@objc public class LeverageValueFormatter: NSObject, ValueFormatterProtocol {
    private static var formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumIntegerDigits = 1
        formatter.minimumFractionDigits = 2
        formatter.minimumSignificantDigits = 2
        formatter.maximumSignificantDigits = 3
        return formatter
    }()

    public func text(value: Any?) -> String? {
        if let value = parser.asDecimal(value) {
            if let string = type(of: self).formatter.string(from: value) {
                return "\(string)x"
            }
        }
        return nil
    }

    public func value(text: String?) -> Any? {
        return parser.asDecimal(text)
    }
}
