//
//  Clock.swift
//  Utilities
//
//  Created by John Huang on 1/14/22.
//  Copyright © 2022 dYdX Trading Inc. All rights reserved.
//

import Foundation

@objc public class Clock: NSObject {
    public static var shared: Clock = Clock()

    private var timer: Timer? {
        didSet {
            didSetTimer(oldValue: oldValue)
        }
    }

    private var refreshingSeconds: Bool = false
    private var refreshSeconds: Bool = true

    public var displayTime: Date? {
        get {
            return nil
        }
        set {
            if let displayTime = newValue, refreshSeconds == false {
                let interval = displayTime.timeIntervalSince(time)
                refreshSeconds = abs(interval) < 120.0
            }
        }
    }

    @objc public dynamic var time: Date = Date()

    override public init() {
        refreshSeconds = true
        super.init()
        updateTimer()
    }

    private func updateTimer() {
        if refreshSeconds != refreshingSeconds || timer === nil {
            refreshingSeconds = refreshSeconds
            timer = Timer.scheduledTimer(withTimeInterval: refreshSeconds ? 1 : 60, repeats: true, block: { [weak self] _ in
                self?.refreshSeconds = false
                self?.time = Date()
            })
        }
    }

    private func didSetTimer(oldValue: Timer?) {
        if timer != oldValue {
            oldValue?.invalidate()
        }
    }
}
