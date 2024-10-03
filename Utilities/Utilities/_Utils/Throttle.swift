//
//  Throttle.swift
//  Utilities
//
//  Created by Qiang Huang on 11/10/21.
//  Copyright © 2021 dYdX Trading Inc. All rights reserved.
//

import Foundation

public class Throttle: NSObject, DebouncerProtocol {
    public var current: DebounceHandler? {
        didSet {
            if current !== oldValue {
                if current !== nil {
                    timerOn = true
                }
            }
        }
    }

    public var runner: DebounceHandler? {
        didSet {
            if runner !== oldValue {
                if runner !== nil {
                    pendingFunction?()
                }
            }
        }
    }

    private var timerOn: Bool = false {
        didSet {
            if timerOn != oldValue {
                if timerOn {
                    if throttleTimer === nil {
                        throttleTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false, block: { [weak self] _ in
                            self?.runner = self?.current
                            self?.timerOn = false
                        })
                    }
                } else {
                    throttleTimer = nil
                }
            }
        }
    }

    private var throttleTimer: Timer? {
        didSet {
            if throttleTimer !== oldValue {
                oldValue?.invalidate()
            }
        }
    }

    private var interval: TimeInterval
    private var pendingFunction: DebouncedFunction?

    public init(interval: TimeInterval) {
        self.interval = interval
        super.init()
    }

    public func debounce() -> DebounceHandler? {
        let debouncer = DebounceHandler(debouncer: self)
        current = debouncer
        return debouncer
    }

    public func ready(handler: DebounceHandler?, function: @escaping DebouncedFunction) {
        self.pendingFunction = function
    }

    @discardableResult open func run(handler: DebounceHandler?, function: @escaping DebouncedFunction) -> Bool {
        if handler === runner {
            handler?.reallyRun(function)
            return true
        }
        return false
    }

    open func finish(handler: DebounceHandler?) {
        if runner === handler {
            runner = nil
        }
    }

    open func cancel(handler: DebounceHandler?) {
        if runner == handler {
            runner = nil
        }
    }

    deinit {
        throttleTimer = nil
    }
}
