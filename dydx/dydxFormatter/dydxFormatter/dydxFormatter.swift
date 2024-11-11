//
//  dydxFormatter.swift
//  dydxModels
//
//  Created by Qiang Huang on 7/22/21.
//  Copyright © 2021 dYdX. All rights reserved.
//

import BigInt
import Utilities
import Combine

public final class dydxFormatter: NSObject, SingletonProtocol {

    public enum DateFormat: String {
        /// "e.g. Jan 1"
        case MMM_d = "MMM d"

        /// "e.g. Jan 1, 2024"
        case MMM_d_yyyy = "MMM d, yyyy"
    }

    private var subscriptions = Set<AnyCancellable>()

    public static let shared = dydxFormatter()

    public override init() {
        super.init()

        DataLocalizer.shared?.languagePublisher
            .sink { [weak self] language in
                self?.updateCalendar(language: language)
            }
            .store(in: &subscriptions)
    }

    private func priceFormatter(withDigits digits: Int) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.minimumFractionDigits = digits
        formatter.maximumFractionDigits = digits
        formatter.currencySymbol = "$"
        return formatter
    }

    private var significantDigitsFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumIntegerDigits = 1
//        formatter.minimumFractionDigits = 2
//        formatter.maximumFractionDigits = 6
        return formatter
    }()

    private var percentFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter
    }()

    private var countFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()

    private var decimalFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()

    private var rawFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        return formatter
    }()

    private var ordinalFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .ordinal
        return formatter
    }()

    public var intervalFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.calendar = Calendar.current
        formatter.unitsStyle = .abbreviated
        formatter.allowedUnits = [.second, .minute, .hour, .day, .month, .year]
        formatter.maximumUnitCount = 1
        formatter.allowsFractionalUnits = false
        formatter.zeroFormattingBehavior = .dropAll
        return formatter
    }()

    public var fullIntervalFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.calendar = Calendar.current
        formatter.unitsStyle = .full
        formatter.allowedUnits = [.second, .minute, .hour, .day, .month, .year]
        formatter.maximumUnitCount = 1
        formatter.allowsFractionalUnits = false
        formatter.zeroFormattingBehavior = .dropAll
        return formatter
    }()

    public var timeFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.calendar = Calendar.current
        formatter.unitsStyle = .positional
        formatter.allowedUnits = [.second, .minute, .hour]
        formatter.maximumUnitCount = 2
        formatter.allowsFractionalUnits = false
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }()

    public var clockFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar.current
        formatter.locale = Locale.current
        formatter.dateFormat = "hh:mm:ss"
        return formatter
    }()

    public var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar.current
        formatter.locale = Locale.current
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }()

    public var datetimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar.current
        formatter.locale = Locale.current
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()

    public var epochFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar.current
        formatter.locale = Locale.current
        formatter.dateFormat = "MMM dd, hh"
        return formatter
    }()

    public var dateIntervalFormatter: DateIntervalFormatter = {
        let formatter = DateIntervalFormatter()
        formatter.timeStyle = .none
        formatter.dateStyle = .medium
        return formatter
    }()

    private func updateCalendar(language: String?) {
        if let language = language {
            var calendar = Calendar.current
            calendar.locale = Locale(identifier: language)
            intervalFormatter.calendar = calendar
            fullIntervalFormatter.calendar = calendar
            dateFormatter.calendar = calendar
            timeFormatter.calendar = calendar
            datetimeFormatter.calendar = calendar
            epochFormatter.calendar = calendar
            dateIntervalFormatter.calendar = calendar
        }
    }

    public func format(decimal: Decimal?) -> String? {
        if let decimal = NSDecimalNumber(decimal: decimal) {
            return format(number: decimal)
        }
        return nil
    }

    public func format(number: Double?) -> String? {
        if let number = number {
            return format(number: NSNumber(value: number))
        }
        return nil
    }

    public func format(number: NSNumber?) -> String? {
        if let number = number {
            if let decimal = number as? NSDecimalNumber {
                return "\(decimal)"
            } else {
                if number.doubleValue.isFinite {
                    return "\(number)"
                } else {
                    return "∞"
                }
            }
        } else {
            return nil
        }
    }

    public func condensed(number: Double?, size: String?) -> String? {
        if let number = number {
            return condensed(number: NSNumber(value: number), size: size)
        }
        return nil
    }

    public func condensed(number: NSNumber?, size: String?) -> String? {
        if let double = number?.doubleValue, double < 1000.0 {
            return localFormatted(number: number, size: size)
        } else {
            return condensed(number: number, digits: 2)
        }
    }

    public func condensed(number: Double?, digits: Int = 4) -> String? {
        if let number = number {
            return condensed(number: NSNumber(value: number), digits: digits)
        }
        return nil
    }

    public func condensed(number: NSNumber?, digits: Int = 4) -> String? {
        if let number = number {
            let postfix = ["", "K", "M", "B", "T"]
            var value = number.decimalValue
            var index = 0
            while value.magnitude >= 1000.0 && index < (postfix.count - 1) {
                value = value / 1000.0
                index += 1
            }
            significantDigitsFormatter.minimumFractionDigits = digits
            significantDigitsFormatter.maximumFractionDigits = digits
            if let numberString = significantDigitsFormatter.string(from: NSDecimalNumber(decimal: value)) {
                return "\(numberString)\(postfix[index])"
            }
        }
        return nil
    }

    public func condensedDollar(number: Double?, digits: Int = 2) -> String? {
        if let number = number {
            let text = condensed(number: NSNumber(value: number), digits: digits)
            if text?.first == "-" {
                return "-$\(text?.dropFirst() ?? "")"
            } else {
                return "$\(text ?? "")"
            }
        }
        return nil
    }

    ///  formats the number as "$" or "-$" of "+$" prefixed
    /// - Parameters:
    ///   - number: the number to format
    ///   - digits: after-decimal precision
    ///   - shouldDisplaySignForPositiveNumbers: whether to include "+" in the prefix for positive numbers
    /// - Returns: the number formatted as a dollar amount
    public func dollarVolume(number: Double?, digits: Int = 2, shouldDisplaySignForPositiveNumbers: Bool = false) -> String? {
        if let number = number {
            return dollarVolume(number: NSNumber(value: number), digits: digits, shouldDisplaySignForPositiveNumbers: shouldDisplaySignForPositiveNumbers)
        }
        return nil
    }

    ///  formats the number as "$" or "-$" of "+$" prefixed
    /// - Parameters:
    ///   - number: the number to format
    ///   - digits: after-decimal precision
    ///   - shouldDisplaySignForPositiveNumbers: whether to include "+" in the prefix for positive numbers
    /// - Returns: the number formatted as a dollar amount
    public func dollarVolume(number: NSNumber?, digits: Int = 2, shouldDisplaySignForPositiveNumbers: Bool = false) -> String? {
        if let number = number,
           let formatted = condensed(number: number.abs(), digits: digits),
           let formattedZero = condensed(number: 0.0, digits: digits) {
            if formattedZero == formatted {
                return "$\(formatted)"
            } else if number.doubleValue >= 0.0 {
                return "\(shouldDisplaySignForPositiveNumbers ? "+" : "")$\(formatted)"
            } else {
                return "-$\(formatted)"
            }
        } else {
            return nil
        }
    }

    public func dollar(number: Double?, size: String? = nil) -> String? {
        if let number = number {
            return dollar(number: NSNumber(value: number), size: size)
        }
        return nil
    }

    public func dollar(number: NSNumber?, size: String? = nil) -> String? {
        if let dollar = localFormatted(number: number?.abs(), size: size ?? "0.01") {
            if (number?.doubleValue ?? Double.zero) >= Double.zero {
                return "$\(dollar)"
            } else {
                return "-$\(dollar)"
            }
        } else {
            return nil
        }
    }

    public func dollar(number: Double?, digits: Int) -> String? {
        if let number = number {
            return dollar(number: NSNumber(value: number), digits: digits)
        }
        return nil
    }

    public func dollar(number: NSNumber?, digits: Int) -> String? {
        let priceFormatter = priceFormatter(withDigits: digits)
        guard let number = number,
              let formatted = priceFormatter.string(from: number) else {
                  return nil
              }
        // need to special case for negative 0, see dydxFormatter tests. E.g. "-$0.001" should go to "$0.00"
        if priceFormatter.number(from: formatted) == 0 {
            return priceFormatter.string(from: 0)
        } else {
            return formatted
        }
    }

    public func localFormatted(number: Double?, size: String?) -> String? {
        if let number = number {
            return localFormatted(number: NSNumber(value: number), size: size)
        }
        return nil
    }

    public func localFormatted(number: NSNumber?, size: String?) -> String? {
        if let size = size {
            let digits = digits(size: size)
            return localDecimal(number: number, digits: digits)
        }
        return localDecimal(number: number, digits: 2)
    }

    public func localFormatted(number: Double?, digits: Int) -> String? {
        if let number = number {
            return localFormatted(number: NSNumber(value: number), digits: digits)
        }
        return nil
    }

    public func localFormatted(number: NSNumber?, digits: Int) -> String? {
        if let number = number {
            let rounded = rounded(number: number, digits: digits)
            return localDecimal(number: rounded, digits: digits)
        } else {
            return nil
        }
    }

    private func localDecimal(number: NSNumber?, digits: Int) -> String? {
        if let number = number {
            decimalFormatter.minimumFractionDigits = max(digits, 0)
            decimalFormatter.maximumFractionDigits = max(digits, 0)
            return decimalFormatter.string(from: number)
        }
        return nil
    }

    public func digits(size: String) -> Int {
        let components = size.components(separatedBy: ".")
        if components.count == 2 {
            return components.last?.count ?? 0
        } else {
            return ((components.first?.count ?? 1) - 1) * -1
        }
    }

    /*
     converts number in multiplier, e.g.
     1.20 -> 1.2x
     removes trailing 0s as well
     */
    public func multiplier(number: Double?, maxPrecision: Int = 2) -> String? {
        if let formattedText = dydxFormatter.shared.raw(number: number, minDigits: 0, maxDigits: maxPrecision) {
            return "\(formattedText)×"
        } else {
            return nil
        }
    }

    /*
     xxxxxx,yyyyy or xxxxx.yyyyy
     will take the number and round it to the closest step size
     e.g. if number is 1021 and step size is "100" then output is "1000"
     */
    public func raw(number: NSNumber?, size: String?, locale: Locale = Locale.current) -> String? {
        if let number = number {
            let size = size ?? "0.01"
            let digits = digits(size: size)
            let rounded = rounded(number: number, digits: digits)
            return raw(number: rounded, digits: digits, locale: locale)
        } else {
            return nil
        }
    }

    /*
     xxxxxx,yyyyy or xxxxx.yyyyy
     will take the number and round it to the closest step size
     e.g. if number is 1021 and step size is "100" then output is "1000"
     */
    public func raw(number: Double?, size: String?, locale: Locale = Locale.current) -> String? {
        guard let number = number else { return nil }
        return raw(number: NSNumber(value: number), size: size, locale: locale)
    }

    /*
     xxxxx.yyyyy
     */
    public func decimalLocaleAgnostic(number: NSNumber?, size: String?) -> String? {
        raw(number: number, size: size, locale: Locale(identifier: "en-US"))
    }

    /*
     xxxxx.yyyyy
     */
    public func decimalLocaleAgnostic(number: NSNumber?, digits: Int) -> String? {
        raw(number: number, digits: digits, locale: Locale(identifier: "en-US"))
    }

    public func raw(number: Double?, digits: Int, locale: Locale = Locale.current) -> String? {
        guard let number = number else { return nil }
        return raw(number: NSNumber(value: number), minDigits: digits, maxDigits: digits, locale: locale)
    }

    public func raw(number: Double?, minDigits: Int, maxDigits: Int, locale: Locale = Locale.current) -> String? {
        guard let number = number else { return nil }
        return raw(number: NSNumber(value: number), minDigits: minDigits, maxDigits: maxDigits, locale: locale)
    }

    public func raw(number: NSNumber?, digits: Int, locale: Locale = Locale.current) -> String? {
        guard let number = number else { return nil }
        return raw(number: number, minDigits: digits, maxDigits: digits, locale: locale)
    }

    public func raw(number: NSNumber?, minDigits: Int, maxDigits: Int, locale: Locale = Locale.current) -> String? {
        if let value = number?.doubleValue {
            if value.isFinite {
                if let number = number {
                    rawFormatter.locale = locale
                    rawFormatter.minimumFractionDigits = max(minDigits, 0)
                    rawFormatter.maximumFractionDigits = max(maxDigits, 0)
                    rawFormatter.roundingMode = .halfUp

                    let formatted = rawFormatter.string(from: number)

                    // need to special case for negative 0, see dydxFormatter tests. E.g. "-$0.001" should go to "$0.00"
                    if let formatted = formatted, rawFormatter.number(from: formatted) == 0 {
                        return rawFormatter.string(from: 0)
                    } else {
                        return formatted
                    }
                } else {
                    return nil
                }
            } else {
                return "∞"
            }
        } else {
            return nil
        }
    }

    /*
     xxxxx.yyyyy
     */
    public func naturalRaw(number: NSNumber?) -> String? {
        return number?.description
    }

    /*
     xxxxxx,yyyyy or xxxxx.yyyyy
     */
    public func naturalFormatted(number: NSNumber?) -> String? {
        return number?.description(withLocale: Locale.current)
    }

    /*
     xxx xxx,yyyyy or xx,xxx.yyyyy
     */
    public func naturalLocalFormatted(number: NSNumber?) -> String? {
        if let decimalSeparator = Locale.current.decimalSeparator {
            let localFormatted = localFormatted(number: number, size: "0.01")
            let naturalFormatted = naturalFormatted(number: number)

            let naturalFormattedComponents = naturalFormatted?.components(separatedBy: decimalSeparator)
            if naturalFormattedComponents?.count == 2, let beforeDecimal = localFormatted?.components(separatedBy: decimalSeparator).first, let afterDecimal = naturalFormattedComponents?.last {
                return "\(beforeDecimal)\(decimalSeparator)\(afterDecimal)"
            } else {
                return localFormatted
            }
        } else {
            return naturalFormatted(number: number)
        }
    }

    private func rounded(number: NSNumber, digits: Int) -> NSNumber {
        if number.doubleValue.isFinite {
            if digits >= 0 {
                return number
            } else {
                let double = number.doubleValue
                let reversed = digits * -1
                let divideBy = pow(10, UInt(reversed))
                let roundedDown = Int(double / Double(divideBy)) * divideBy
                return NSNumber(value: roundedDown)
            }
        } else {
            return number
        }
    }

    public func percent(number: Double?, digits: Int, minDigits: Int? = nil, shouldDisplayPlusSignForPositiveNumbers: Bool = false) -> String? {
        if let number = number {
            return percent(number: NSNumber(value: number), digits: digits, minDigits: minDigits, shouldDisplayPlusSignForPositiveNumbers: shouldDisplayPlusSignForPositiveNumbers)
        }
        return nil
    }

    public func percent(number: NSNumber?, digits: Int, minDigits: Int? = nil, shouldDisplayPlusSignForPositiveNumbers: Bool = false) -> String? {
        if let number = number {
            if number.doubleValue.isFinite {
                let percent = NSNumber(value: number.doubleValue * 100.0)
                percentFormatter.minimumFractionDigits = minDigits ?? digits
                percentFormatter.maximumFractionDigits = digits
                if let formatted = percentFormatter.string(from: percent.abs()),
                   let formattedZero = percentFormatter.string(from: 0) {
                    if formattedZero == formatted {
                        return "\(formatted)%"
                    } else if number.doubleValue >= 0.0 {
                        return "\(shouldDisplayPlusSignForPositiveNumbers ? "+" : "")\(formatted)%"
                    } else if number.doubleValue < 0.0 {
                        return "-\(formatted)%"
                    } else {
                        return nil
                    }
                } else {
                    return nil
                }
            } else {
                return "—"
            }
        } else {
            return nil
        }
    }

    public func leverage(number: Double?, digits: Int = 2) -> String? {
        if let number = number {
            return leverage(number: NSNumber(value: number), digits: digits)
        }
        return nil
    }

    public func leverage(number: NSNumber?, digits: Int = 2) -> String? {
        if let number = number?.abs() {
            if number.doubleValue.isFinite {
                percentFormatter.minimumFractionDigits = digits
                percentFormatter.maximumFractionDigits = digits
                if let formatted = percentFormatter.string(from: number) {
                    return "\(formatted)x"
                } else {
                    return nil
                }
            } else {
                return "—"
            }
        } else {
            return nil
        }
    }

    public func interval(time: Date?) -> String? {
        if let time = time {
            var interval = time.timeIntervalSince(Date())
            if interval < 0.0 {
                interval *= -1
            }
            return intervalFormatter.string(from: interval)
        } else {
            return nil
        }
    }

    public func fullInterval(time: Date?) -> String? {
        if let time = time {
            var interval = time.timeIntervalSince(Date())
            if interval < 0.0 {
                interval *= -1
            }
            return fullIntervalFormatter.string(from: interval)
        } else {
            return nil
        }
    }

    public func time(time: Date?) -> String? {
        if let time = time {
            var interval = time.timeIntervalSince(Date())
            if interval < 0.0 {
                interval *= -1
            }
            if interval >= 3600 {
                timeFormatter.allowedUnits = [.second, .minute, .hour]
            } else {
                timeFormatter.allowedUnits = [.second, .minute]
            }
            return timeFormatter.string(from: interval)
        } else {
            return nil
        }
    }

    public func clock(time: Date?) -> String? {
        if let time = time {
            return clockFormatter.string(from: time)
        } else {
            return nil
        }
    }

    public func shorten(ethereumAddress: String?) -> String? {
        if let ethereumAddress = ethereumAddress {
            return "\(ethereumAddress.substring(toIndex: 6))...\(ethereumAddress.substring(fromIndex: ethereumAddress.length - 4))"
        } else {
            return nil
        }
    }

    public func marker(ethereumAddress: String?) -> String? {
        if let ethereumAddress = ethereumAddress {
            return ethereumAddress.substring(toIndex: 4)
        } else {
            return nil
        }
    }

    public func range(start: Date?, end: Date?) -> String? {
        if let start = start {
            if let end = end {
                return dateIntervalFormatter.string(from: start, to: end)
            } else {
                return "from \(dateFormatter.string(from: start))"
            }
        } else {
            if let end = end {
                return " to \(dateFormatter.string(from: end))"
            } else {
                return nil
            }
        }
    }

    public func epoch(date: Date?) -> String? {
        if let date = date {
            return dateFormatter.string(from: date)
        } else {
            return nil
        }
    }

    /// returns a formatted date in the form `M/D/YY, H:MM PM/AM`
    ///
    /// e.g. `12/5/23, 6:02 PM`
    public func dateAndTime(date: Date?) -> String? {
        if let date = date {
            return datetimeFormatter.string(from: date)
        } else {
            return nil
        }
    }

    public func millisecondsToDate(_ milliseconds: Double, format: DateFormat) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
        let formatter = datetimeFormatter
        formatter.dateFormat = format.rawValue
        return datetimeFormatter.string(from: date)
    }

    public func multiple(of tickText: String, is sizeText: String) -> Bool {
        let components: [String] = tickText.components(separatedBy: ".")
        if components.count == 2 { // decimal
            let decimal = components[1]
            let length = decimal.count
            let scaledTickSize = parser.asInt(decimal) ?? 0
            if scaledTickSize != 0 {
                let sizeComponents = sizeText.components(separatedBy: ".")
                var scaledSize = (parser.asInt(sizeComponents[0]) ?? 0) * pow(10, UInt(length))
                let sizeDecimal = parser.asInt(components[0].pad(to: length, with: "0")) ?? 0
                scaledSize += sizeDecimal
                return scaledSize % scaledTickSize == 0
            } else {
                return false
            }
        } else {
            if let tickSize = parser.asInt(tickText), let size = parser.asInt(sizeText) {
                if tickSize != 0 {
                    return size % tickSize == 0
                } else {
                    return true
                }
            } else {
                return false
            }
        }
    }

    func pow(_ base: Int, _ power: UInt) -> Int {
        var answer: Int = 1
        for _ in 0 ..< power { answer *= base }
        return answer
    }

    public func ordinal(number: Int?) -> String? {
        if let number = number {
            return ordinalFormatter.string(from: NSNumber(value: number))
        } else {
            return nil
        }
    }
}
