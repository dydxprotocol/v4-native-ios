//
//  Debouncer.swift
//  Utilities
//
//  Created by John Huang on 10/21/18.
//  Copyright © 2019 dYdX. All rights reserved.
//

import Foundation

public typealias DebouncedFunction = () -> Void

public protocol DebouncerProtocol: NSObjectProtocol {
    func ready(handler: DebounceHandler?, function: @escaping DebouncedFunction)
    @discardableResult func run(handler: DebounceHandler?, function: @escaping DebouncedFunction) -> Bool
    func finish(handler: DebounceHandler?)
    func cancel(handler: DebounceHandler?)
}

public class Debouncer: NSObject, DebouncerProtocol {
    public var current: DebounceHandler? {
        didSet {
            didSetCurrent(oldValue: oldValue)
        }
    }

    internal var previous: DebounceHandler?

    public var fifo: Bool = false

    override public init() {
        super.init()
    }

    public init(fifo: Bool) {
        self.fifo = fifo
        super.init()
    }

    open func didSetCurrent(oldValue: DebounceHandler?) {
        if current !== oldValue {
            if current != nil {
                previous = current
            }
        }
    }

    public func debounce() -> DebounceHandler? {
        if !fifo || current == nil {
            let debouncer = DebounceHandler(debouncer: self)
            current = debouncer
            return debouncer
        }
        return nil
    }

    public func ready(handler: DebounceHandler?, function: @escaping DebouncedFunction) {
        function()
    }

    @discardableResult open func run(handler: DebounceHandler?, function: @escaping DebouncedFunction) -> Bool {
        if handler === current {
            handler?.reallyRun(function)
            return true
        }
        return false
    }

    open func finish(handler: DebounceHandler?) {
        if fifo, current === handler {
            current = nil
        }
    }

    open func cancel(handler: DebounceHandler?) {
        if current == handler {
            current = nil
        }
    }
}

public class DebounceHandler: NSObject {
    private weak var debouncer: DebouncerProtocol?

    public init(debouncer: DebouncerProtocol) {
        self.debouncer = debouncer
        super.init()
    }

    public func run(_ function: @escaping DebouncedFunction, delay: TimeInterval?, finish: Bool = true) {
        let backgrounds: [DebouncedFunction?] = []
        run(backgrounds: backgrounds, final: function, delay: delay)
    }

    open func reallyRun(_ function: @escaping DebouncedFunction) {
        function()
    }

    public func run(background: @escaping DebouncedFunction, final: @escaping DebouncedFunction, delay: TimeInterval?) {
        let backgrounds: [DebouncedFunction?] = [background]
        run(backgrounds: backgrounds, final: final, delay: delay)
    }

    public func run(background: @escaping DebouncedFunction, then: @escaping DebouncedFunction, final: @escaping DebouncedFunction, delay: TimeInterval?) {
        let backgrounds: [DebouncedFunction?] = [background, then]
        run(backgrounds: backgrounds, final: final, delay: delay)
    }

    public func run(background: @escaping DebouncedFunction, then: @escaping DebouncedFunction, then another: @escaping DebouncedFunction, final: @escaping DebouncedFunction, delay: TimeInterval?) {
        let backgrounds: [DebouncedFunction?] = [background, then, another]
        run(backgrounds: backgrounds, final: final, delay: delay)
    }

    open func run(backgrounds: [DebouncedFunction?], final: @escaping DebouncedFunction, delay: TimeInterval?) {
        debouncer?.ready(handler: self, function: {[weak self] in
            self?.reallyRun(backgrounds: backgrounds, final: final, delay: delay)
        })
    }

    open func reallyRun(backgrounds: [DebouncedFunction?], final: @escaping DebouncedFunction, delay: TimeInterval?) {
        if let first = backgrounds.first {
            var leftOver = backgrounds
            leftOver.removeFirst()
            if let first = first {
                DispatchQueue.global().asyncAfter(deadline: .now() + (delay ?? 0)) { [weak self] in
                    if let self = self {
                        let ran = self.debouncer?.run(handler: self, function: first)
                        if let ran = ran, ran {
                            self.run(backgrounds: leftOver, final: final, delay: 0)
                        }
                    }
                }
            } else {
                run(backgrounds: leftOver, final: final, delay: delay)
            }
        } else {
            let direct = Thread.isMainThread && delay == nil
            if direct {
                if debouncer?.run(handler: self, function: final) ?? false {
                    debouncer?.finish(handler: self)
                }
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + (delay ?? 0)) { [weak self] in
                    if let self = self {
                        if self.debouncer?.run(handler: self, function: final) ?? false {
                            self.debouncer?.finish(handler: self)
                        }
                    }
                }
            }
        }
    }

    public func cancel() {
        debouncer?.cancel(handler: self)
    }

    deinit {
    }
}
