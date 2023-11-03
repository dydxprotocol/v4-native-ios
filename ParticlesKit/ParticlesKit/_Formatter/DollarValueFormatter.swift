//
//  DollarValueFormatter.swift
//  ParticlesKit
//
//  Created by Qiang Huang on 6/10/21.
//  Copyright © 2021 dYdX. All rights reserved.
//

import Utilities

@objc public class DollarValueFormatter: NSObject, ValueFormatterProtocol {
    private static var formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.numberStyle = .currency
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
        return parser.asDecimal(text?.replacingOccurrences(of: "$", with: "").replacingOccurrences(of: ",", with: ""))
    }
}
