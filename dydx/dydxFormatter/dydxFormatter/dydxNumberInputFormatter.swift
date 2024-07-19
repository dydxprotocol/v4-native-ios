//
//  dydxNumberInputFormatter.swift
//  dydxFormatter
//
//  Created by Michael Maguire on 7/19/24.
//

import Foundation

/// a number formatter that also supports rounding to nearest 10/100/1000/etc
/// formatter is intended for user inputs, so group separator is omitted, i.e. the "," in "1,000"
public class dydxNumberInputFormatter: Formatter {
    public private(set) var fractionDigits: Int
    public let shouldIncludeInsignificantZeros: Bool

    /// - Parameter fractionDigits: if greater than 0, numbers will be rounded to nearest 10, 100, 1000, etc. If less than 0 numbers will be rounded to nearest 0.1, 0.01, .001
    /// - Parameter shouldIncludeInsignificantZeros: If fractionDigits is less than 0, trailing zeros will be truncated
    public init(fractionDigits: Int, shouldIncludeInsignificantZeros: Bool = false) {
        self.fractionDigits = fractionDigits
        self.shouldIncludeInsignificantZeros = shouldIncludeInsignificantZeros
        super.init()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func format(_ number: Double) -> String {
        if fractionDigits < 0 {
            return roundToNearestMultiple(number: number, multiple: pow(10, Double(-fractionDigits)))
        } else {
            return roundToFractionDigits(number: number)
        }
    }

    private func roundToNearestMultiple(number: Double, multiple: Double) -> String {
        let roundedValue = (number / multiple).rounded() * multiple
        return String(Int(roundedValue))
    }

    private lazy var numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = shouldIncludeInsignificantZeros ? fractionDigits : 0
        formatter.maximumFractionDigits = fractionDigits
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = false
        return formatter
    }()

    private func roundToFractionDigits(number: Double) -> String {
        numberFormatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }

    override public func string(for obj: Any?) -> String? {
        guard let number = obj as? Double else {
            return nil
        }
        return format(number)
    }

    public override func getObjectValue(_ obj: AutoreleasingUnsafeMutablePointer<AnyObject?>?, for string: String, errorDescription: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {
        if let number = numberFormatter.number(from: string) {
            obj?.pointee = number
            return true
        } else {
            errorDescription?.pointee = "Could not convert string to number" as NSString
            return false
        }
    }
}
