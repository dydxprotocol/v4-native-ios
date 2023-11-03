//
//  Throttler.swift
//  Utilities
//
//  Created by Qiang Huang on 11/8/21.
//  Copyright © 2021 dYdX Trading Inc. All rights reserved.
//

import Foundation

public class Throttler: Debouncer {
//    public var throttleInterval: TimeInterval = 0.1
//    private var throttleStart: Date?
//    public var last: DebounceHandler?
//    
//    public init(throttleInterval: TimeInterval = 0.1) {
//        super.init()
//        self.throttleInterval = throttleInterval
//    }
//
//    @discardableResult override public func run(handler: DebounceHandler?, function: @escaping DebouncedFunction) -> Bool {
//        if let throttleStart = throttleStart {
//            if Date().timeIntervalSince(throttleStart) >= throttleInterval {
//                if last === nil {
//                    last = handler
//                }
//            }
//            if handler === last {
//                handler?.reallyRun(function)
//                return true
//            } else {
//                return false
//            }
//        } else {
//            throttleStart = Date()
//            return false
//        }
//    }
//    
//    open override func finish(handler: DebounceHandler?) {
//        if handler === last {
//            last = nil
//            throttleStart = nil
//        } else {
//            super.finish(handler: handler)
//        }
//    }
}
