//
//  Date+Utils.swift
//  Utilities
//
//  Created by Qiang Huang on 10/8/18.
//  Copyright © 2018 dYdX. All rights reserved.
//

import Foundation

public extension Date {
    static var iso8601Formatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    static var gmtFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en-US")
        let gmt = NSTimeZone(abbreviation: "GMT")
        if let aGmt = gmt {
            formatter.timeZone = aGmt as TimeZone
        }
        formatter.dateFormat = nil
        formatter.dateStyle = .none
        formatter.timeStyle = .none

        return formatter
    }()

    static var localFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en-US")
        formatter.timeZone = NSTimeZone.local as TimeZone
        formatter.dateFormat = nil
        formatter.dateStyle = .none
        formatter.timeStyle = .none
        return formatter
    }()

    static func date(serverString: String) -> Date? {
        let formatter = localFormatter
        formatter.dateFormat = "M/d/y"
        return formatter.date(from: serverString)
    }

    var serverDateString: String {
        let formatter = type(of: self).localFormatter
        formatter.dateFormat = "M/d/y"
        return formatter.string(from: self)
    }

    static func datetime(gmtServerString: String?) -> Date? {
        if let gmtServerString = gmtServerString {
            let formatter = gmtFormatter
            formatter.dateFormat = "MM/dd/yyyy H:mm:ss"
            var datetime = formatter.date(from: gmtServerString)
            if datetime == nil {
                formatter.dateFormat = "MM/dd/yyyy h:mm:ss a"
                datetime = formatter.date(from: gmtServerString)
            }
            if datetime == nil {
                formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
                datetime = formatter.date(from: gmtServerString)
            }
            return datetime
        }
        return nil
    }

    static func datetime(iso8601ServerString: String?) -> Date? {
        if let iso8601ServerString = iso8601ServerString {
            return iso8601Formatter.date(from: iso8601ServerString)
        }
        return nil
    }

    var gmtServerDatetimeString: String {
        let formatter = type(of: self).gmtFormatter
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        return formatter.string(from: self)
    }

    var utcServerDatetimeString: String {
        let formatter = type(of: self).localFormatter
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSxxx"
        return formatter.string(from: self)
    }

    var iso8601ServerDatetimeString: String {
        return type(of: self).iso8601Formatter.string(from: self)
    }

    static func datetime(gmtSqliteString: String) -> Date? {
        let formatter = gmtFormatter
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.date(from: gmtSqliteString)
    }

    var gmtSqliteDatetimeString: String {
        let formatter = type(of: self).gmtFormatter
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: self)
    }

    static func date(gmtSqliteString: String?) -> Date? {
        if let gmtSqliteString = gmtSqliteString {
            let formatter = gmtFormatter
            formatter.dateFormat = "yyyy-MM-dd"
            return formatter.date(from: gmtSqliteString)
        }
        return nil
    }

    var gmtSqliteDateString: String {
        let formatter = type(of: self).gmtFormatter
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: self)
    }

    var localDatetimeString: String {
        let formatter = type(of: self).localFormatter
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }

    var localLongDateString: String {
        let formatter = type(of: self).localFormatter
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter.string(from: self)
    }

    var localLongTimeString: String {
        let formatter = type(of: self).localFormatter
        formatter.dateStyle = .none
        formatter.timeStyle = .long
        return formatter.string(from: self)
    }

    var localDateString: String {
        let formatter = type(of: self).localFormatter
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter.string(from: self)
    }

    var localTimeString: String {
        let formatter = type(of: self).localFormatter
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }

    static func date(string: String) -> Date? {
        let formatter = localFormatter
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.date(from: string)
    }

    var englishDatetimeString: String {
        let formatter = type(of: self).localFormatter
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }

    var timeString: String {
        let formatter = type(of: self).localFormatter
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }

    func add(month: Int) -> Date? {
        let gregorian = Calendar(identifier: .gregorian)
        var components = DateComponents()
        components.month = month
        return gregorian.date(byAdding: components, to: self)
    }

    func add(day: Int) -> Date? {
        let gregorian = Calendar(identifier: .gregorian)
        var components = DateComponents()
        components.day = day
        return gregorian.date(byAdding: components, to: self)
    }
}

public extension Date {
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }

    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay)!
    }

    var tomorrow: Date {
        var components = DateComponents()
        components.day = 1
        return Calendar.current.date(byAdding: components, to: self)!
    }

    var startOfMonth: Date {
        let components = Calendar.current.dateComponents([.year, .month], from: startOfDay)
        return Calendar.current.date(from: components)!
    }

    var endOfMonth: Date {
        var components = DateComponents()
        components.month = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfMonth)!
    }

    var nextHour: Date {
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour], from: self)
        return Calendar.current.date(from: components)!.addingTimeInterval(3600)
    }
}
