//
//  NSNumber+Format.swift
//  Utilities
//
//  Created by Qiang Huang on 4/16/21.
//  Copyright © 2021 dYdX. All rights reserved.
//

import Foundation

public extension NSNumber {
    private static var currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.numberStyle = .currency
        return formatter
    }()

    private static var deepDollorFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.numberStyle = .currency
        formatter.minimumIntegerDigits = 1
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 6
        formatter.minimumSignificantDigits = 1
        formatter.maximumSignificantDigits = 7
        return formatter
    }()

    private static var percentageFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.minimumIntegerDigits = 1
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.minimumSignificantDigits = 1
        formatter.maximumSignificantDigits = 3
        return formatter
    }()

    private static var deepPercentageFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.minimumIntegerDigits = 1
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 6
        formatter.minimumSignificantDigits = 1
        formatter.maximumSignificantDigits = 7
        return formatter
    }()

    private static var significantDigitsFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumIntegerDigits = 1
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 6
        formatter.minimumSignificantDigits = 1
        formatter.maximumSignificantDigits = 5
        return formatter
    }()

    /*
     func asCurrency() -> String? {
         return NSNumber.currencyFormatter.string(from: self)
     }

     func asDollarVolume() -> String? {
         let postfix = ["", "K", "M", "B", "T"]
         var value = decimalValue
         var index = 0
         while value > 1000.0 && index < (postfix.count - 1) {
             value = value / 1000.0
             index += 1
         }
         if let numberString = NSNumber.significantDigitsFormatter.string(from: NSDecimalNumber(decimal: value)) {
             return "\(numberString)\(postfix[index])"
         }
         return nil
     }

     func asPercentage() -> String? {
         return NSNumber.percentageFormatter.string(from: self)
     }

     func asDeepPercentage() -> String? {
         return NSNumber.deepPercentageFormatter.string(from: self)
     }

      */

    @objc func abs() -> NSNumber {
        return NSNumber(value: Swift.abs(doubleValue))
    }

    @objc func positiveOrZero() -> Bool {
        return doubleValue >= 0.0
    }

    @objc func negative() -> NSNumber {
        return NSNumber(value: doubleValue * -1.0)
    }

    @objc func floor(_ minimum: Double) -> NSNumber {
        if doubleValue >= minimum {
            return self
        } else {
            return NSNumber(value: minimum)
        }
    }
}

public extension NSDecimalNumber {
    override func abs() -> NSNumber {
        return NSDecimalNumber(decimal: Swift.abs(decimalValue))
    }

    override func positiveOrZero() -> Bool {
        return decimalValue >= 0.0
    }

    convenience init?(decimal: Decimal?) {
        if let decimal = decimal {
            self.init(decimal: decimal)
        } else {
            return nil
        }
    }
}

public extension Decimal {
    var doubleValue: Double {
        return NSDecimalNumber(decimal: self).doubleValue
    }
}
