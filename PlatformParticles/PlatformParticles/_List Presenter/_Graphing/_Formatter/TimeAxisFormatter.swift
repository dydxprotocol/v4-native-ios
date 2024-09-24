//
//  TimeAxisFormater.swift
//  PlatformParticles
//
//  Created by Qiang Huang on 9/28/21.
//  Copyright © 2021 dYdX. All rights reserved.
//

import DGCharts
import Foundation

@objc public enum DateTimeResolution: Int {
    case minute1
    case minute5
    case minute15
    case minute30
    case hour1
    case hour4
    case day1
}

@objc public class TimeAxisFormatter: GraphingAxisFormater {
    public static var minuteFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        return formatter
    }()

    public static var hourFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        return formatter
    }()

    public static var dayFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.day]
        return formatter
    }()

    public static var monthFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.month]
        return formatter
    }()

    @objc public dynamic var resolution: DateTimeResolution = .day1

    override open func stringForValue(_ value: Double, axis _: AxisBase?) -> String {
        let datetime = Date(timeIntervalSince1970: value)

        return formatString(datetime: datetime) ?? ""
    }

    public func formatString(datetime: Date) -> String? {
        let components = Calendar.current.dateComponents([.day, .hour, .minute], from: datetime)
        switch resolution {
        case .minute1:
            if let minute = components.minute, minute % 5 == 0 {
                return type(of: self).minuteFormatter.string(from: components)
            } else {
                return nil
            }

        case .minute5:
            if let minute = components.minute, minute % 30 == 0 {
                return type(of: self).minuteFormatter.string(from: components)
            } else {
                return nil
            }

        case .minute15:
            if let minute = components.minute, minute == 0 {
                return type(of: self).hourFormatter.string(from: components)
            } else {
                return nil
            }

        case .minute30:
            if let minute = components.minute, let hour = components.hour, minute == 0, hour % 3 == 0 {
                return type(of: self).hourFormatter.string(from: components)
            } else {
                return nil
            }

        case .hour1:
            if let minute = components.minute, let hour = components.hour, minute == 0, hour % 6 == 0 {
                return type(of: self).hourFormatter.string(from: components)
            } else {
                return nil
            }

        case .hour4:
            if let minute = components.minute, let hour = components.hour, minute == 0, hour == 0 {
                return type(of: self).dayFormatter.string(from: components)
            } else {
                return nil
            }

        case .day1:
            if let minute = components.minute, let hour = components.hour, let day = components.day, minute == 0, hour == 0, (day - 1) % 4 == 0 {
                if day == 1 {
                    return type(of: self).monthFormatter.string(from: components)
                } else {
                    return type(of: self).dayFormatter.string(from: components)
                }
            } else {
                return nil
            }

        default:
            return nil
        }
    }
}
