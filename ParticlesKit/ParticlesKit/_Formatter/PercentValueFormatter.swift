//
//  PercentValueFormatter.swift
//  ParticlesKit
//
//  Created by Qiang Huang on 6/10/21.
//  Copyright © 2021 dYdX. All rights reserved.
//

import Utilities

@objc public class PercentValueFormatter: NSObject, ValueFormatterProtocol {
    private static var formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
//        formatter.minimumIntegerDigits = 1
//        formatter.minimumFractionDigits = 2
//        formatter.maximumFractionDigits = 2
//        formatter.minimumSignificantDigits = 1
//        formatter.maximumSignificantDigits = 3

        formatter.minimumIntegerDigits = 1
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.minimumSignificantDigits = 3
        formatter.maximumSignificantDigits = 5
        return formatter
    }()

    public func text(value: Any?) -> String? {
        if let value = parser.asDecimal(value) {
            return type(of: self).formatter.string(from: value)
        } else {
            return nil
        }
    }

    public func value(text: String?) -> Any? {
        return parser.asDecimal(text?.replacingOccurrences(of: "%", with: ""))?.dividing(by: NSDecimalNumber(value: 100))
    }
}
