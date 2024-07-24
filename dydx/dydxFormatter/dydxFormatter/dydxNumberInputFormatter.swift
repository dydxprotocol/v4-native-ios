//
//  dydxNumberInputFormatter.swift
//  dydxFormatter
//
//  Created by Michael Maguire on 7/19/24.
//

import Foundation

/// a number formatter that also supports rounding to nearest 10/100/1000/etc
/// formatter is intended for user inputs, so group separator is omitted, i.e. the "," in "1,000"
public class dydxNumberInputFormatter: NumberFormatter, ObservableObject {

    /// if greater than 0, numbers will be rounded to nearest 10, 100, 1000, etc. If less than 0 numbers will be rounded to nearest 0.1, 0.01, .001
    public var fractionDigits: Int {
        get {
            maximumFractionDigits
        }
        set {
            if maximumFractionDigits != newValue || minimumFractionDigits != newValue {
                maximumFractionDigits = newValue
                minimumFractionDigits = newValue
                objectWillChange.send()
            }
        }
    }

    /// Use this initializer
    /// - Parameter fractionDigits: if greater than 0, numbers will be rounded to nearest 10, 100, 1000, etc. If less than 0 numbers will be rounded to nearest 0.1, 0.01, .001
    public convenience init(fractionDigits: Int = 2) {
        self.init()
        self.maximumFractionDigits = fractionDigits
        self.minimumFractionDigits = fractionDigits
        self.numberStyle = .decimal
        self.usesGroupingSeparator = false
    }

    public override func string(from number: NSNumber) -> String? {
        if maximumFractionDigits < 0 {
            return String(Int(number.doubleValue.round(to: maximumFractionDigits)))
        } else {
            return super.string(from: number)
        }
    }
}
