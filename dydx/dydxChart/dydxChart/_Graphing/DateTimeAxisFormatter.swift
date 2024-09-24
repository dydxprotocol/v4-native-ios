//
//  DateTimeAxisFormatter.swift
//  dydxPlatformParticles
//
//  Created by Qiang Huang on 11/3/21.
//  Copyright © 2021 dYdX Trading Inc. All rights reserved.
//

import DGCharts
import dydxFormatter
import Utilities
import Foundation

@objc public enum FormatType: Int {
    case minute
    case hour
    case day
}

@objc open class DateTimeAxisFormatter: NSObject, IAxisValueFormatter {
    static var timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar.current
        formatter.locale = Locale.current
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()

    static var dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar.current
        formatter.locale = Locale.current
        formatter.dateStyle = .none
        formatter.timeStyle = .none
        formatter.dateFormat = "d"
        return formatter
    }()

    static var monthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar.current
        formatter.locale = Locale.current
        formatter.dateStyle = .none
        formatter.timeStyle = .none
        formatter.dateFormat = "MMM"
        return formatter
    }()

    static var monthAndDayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar.current
        formatter.locale = Locale.current
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        formatter.dateFormat = "MMM d"
        return formatter
    }()

    @objc public var resolution: CandleResolution = .ONEHOUR {
        didSet {
            didSetResolution(oldValue: oldValue)
        }
    }

    @objc public var type: FormatType = FormatType.day

    private var previousTime: DateComponents?

    private func didSetResolution(oldValue: CandleResolution) {
        if resolution != oldValue {
            switch resolution {
            case .ONEMIN:
                fallthrough
            case .FIVEMINS:
                fallthrough
            case .FIFTEENMINS:
                fallthrough
            case .THIRTYMINS:
                type = .minute

            case .ONEHOUR:
                fallthrough
            case .FOURHOURS:
                type = .hour

            default:
                type = .day
            }
        }
    }

    internal func unitInterval() -> Double {
        switch resolution {
        case .FIVEMINS:
            return 60.0 * 5

        case .FIFTEENMINS:
            return 60.0 * 15

        case .THIRTYMINS:
            return 60.0 * 30

        case .ONEHOUR:
            return 60.0 * 60

        case .FOURHOURS:
            return 60.0 * 60 * 4

        case .ONEDAY:
            return 60.0 * 60 * 24

        case .ONEMIN:
            fallthrough
        default:
            return 60.0
        }
    }

    open func stringForValue(_ value: Double, axis _: AxisBase?) -> String {
        var result: String = ""
        if let anchor = GraphingAnchor.shared?.date {
            // what is 2500 here?
            let time = anchor.addingTimeInterval(unitInterval() * (Double(Int(value)) - 2500.0))
            switch resolution {
            case .unknown:
                break

            case .ONEMIN:
                let components = Calendar.current.dateComponents([.hour, .minute], from: time)
                if let minute = components.minute {
                    if minute == 0 {
                        if components.hour == 0 {
                            result = DateTimeAxisFormatter.monthAndDayFormatter.string(from: time)
                        } else {
                            result = DateTimeAxisFormatter.timeFormatter.string(from: time)
                        }
                    } else {
                        result = DateTimeAxisFormatter.timeFormatter.string(from: time)
                    }
                }

            case .FIVEMINS:
                let components = Calendar.current.dateComponents([.hour, .minute], from: time)
                if let minute = components.minute {
                    if minute == 0 {
                        if components.hour == 0 {
                            result = DateTimeAxisFormatter.monthAndDayFormatter.string(from: time)
                        } else {
                            result = DateTimeAxisFormatter.timeFormatter.string(from: time)
                        }
                    } else {
                        result = DateTimeAxisFormatter.timeFormatter.string(from: time)
                    }
                }

            case .FIFTEENMINS:
                let components = Calendar.current.dateComponents([.hour, .minute], from: time)
                if components.hour == 0 {
                    result = DateTimeAxisFormatter.monthAndDayFormatter.string(from: time)
                } else {
                    result = DateTimeAxisFormatter.timeFormatter.string(from: time)
                }

            case .THIRTYMINS:
                let components = Calendar.current.dateComponents([.hour, .minute], from: time)
                if components.hour == 0 {
                    result = DateTimeAxisFormatter.monthAndDayFormatter.string(from: time)
                } else {
                    result = DateTimeAxisFormatter.timeFormatter.string(from: time)
                }

            case .ONEHOUR:
                fallthrough
//                let components = Calendar.current.dateComponents([.hour], from: time)
//                if let hour = components.hour {
//                    if hour == 0 {
//                        result = DateTimeAxisFormatter.monthAndDayFormatter.string(from: time)
//                    } else {
//                        result = DateTimeAxisFormatter.timeFormatter.string(from: time)
//                    }
//                }

            case .FOURHOURS:
                let components = Calendar.current.dateComponents([.month, .day, .hour], from: time)
                    if components.day != previousTime?.day {
                        result = DateTimeAxisFormatter.monthAndDayFormatter.string(from: time)
                    } else {
                        result = DateTimeAxisFormatter.timeFormatter.string(from: time)
                    }
                previousTime = components

            case .ONEDAY:
                let components = Calendar.current.dateComponents([.month, .day], from: time)
                if let day = components.day {
                    if day == 1 {
                        result = DateTimeAxisFormatter.monthFormatter.string(from: time)
                    } else {
                        result = DateTimeAxisFormatter.monthAndDayFormatter.string(from: time)
                    }
                }
            }
        }
        return result
    }
}

@objc public enum CandleResolution: Int {
   case unknown
   case ONEMIN
   case FIVEMINS
   case FIFTEENMINS
   case THIRTYMINS
   case ONEHOUR
   case FOURHOURS
   case ONEDAY

   public var v4Key: String {
       switch self {
       case .unknown:
           return "1HOUR"
       case .ONEMIN:
           return "1MIN"
       case .FIVEMINS:
           return "5MINS"
       case .FIFTEENMINS:
           return "15MINS"
       case .THIRTYMINS:
           return "30MINS"
       case .ONEHOUR:
           return "1HOUR"
       case .FOURHOURS:
           return "4HOURS"
       case .ONEDAY:
           return "1DAY"
       }
   }
}
