//
//  SynchronizedLock.swift
//  Utilities
//
//  Created by Michael Maguire on 5/2/24.
//  Copyright © 2024 dYdX Trading Inc. All rights reserved.
//

import Darwin

@propertyWrapper
public struct SynchronizedLock<Value> {
    private var value: Value
    private var lock = NSLock()

    public var wrappedValue: Value {
        get { lock.synchronized { value } }
        set { lock.synchronized { value = newValue } }
    }

    public init(wrappedValue value: Value) {
        self.value = value
    }
}

private extension NSLock {

    @discardableResult
    func synchronized<T>(_ block: () -> T) -> T {
        lock()
        defer { unlock() }
        return block()
    }
}
