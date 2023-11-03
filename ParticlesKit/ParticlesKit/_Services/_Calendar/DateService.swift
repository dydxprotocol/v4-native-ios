//
//  File.swift
//  Utilities
//
//  Created by Qiang Huang on 11/25/18.
//  Copyright © 2018 dYdX. All rights reserved.
//

import Foundation

public protocol DateProviderProtocol {
    func now() -> Date
}

public class DateService {
    public static var shared: DateProviderProtocol?
}

public class RealDateProvider: DateProviderProtocol {
    public init() {
    }

    public func now() -> Date {
        return Date()
    }
}

public class FixedDateProvider: DateProviderProtocol {
    private var date: Date?

    public required init(date: Date?) {
        self.date = date
    }

    public func now() -> Date {
        return date ?? Date()
    }
}
