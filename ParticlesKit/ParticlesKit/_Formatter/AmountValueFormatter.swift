//
//  AmountValueFormatter.swift
//  ParticlesKit
//
//  Created by Qiang Huang on 6/10/21.
//  Copyright © 2021 dYdX. All rights reserved.
//

import Utilities

@objc public class AmountValueFormatter: NSObject, ValueFormatterProtocol {
    private static var formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumIntegerDigits = 1
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 6
        formatter.minimumSignificantDigits = 1
        formatter.maximumSignificantDigits = 5
        return formatter
    }()

    public func text(value: Any?) -> String? {
        if let value = parser.asDecimal(value) {
            let postfix = ["", "K", "M", "B", "T"]
            var decimal = value.decimalValue
            var index = 0
            while decimal > 1000.0 && index < (postfix.count - 1) {
                decimal = decimal / 1000.0
                index += 1
            }
            if let numberString = type(of: self).formatter.string(from: NSDecimalNumber(decimal: decimal)) {
                return "\(numberString)\(postfix[index])"
            }
        }
        return nil
    }

    public func value(text: String?) -> Any? {
        return parser.asDecimal(text?.replacingOccurrences(of: "T", with: "").replacingOccurrences(of: "B", with: "").replacingOccurrences(of: "M", with: "").replacingOccurrences(of: "K", with: "").replacingOccurrences(of: ",", with: ""))
    }
}
