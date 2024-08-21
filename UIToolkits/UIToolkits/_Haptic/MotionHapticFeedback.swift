//
//  HapticFeedback.swift
//  UIToolkits
//
//  Created by Qiang Huang on 10/30/21.
//  Copyright © 2021 dYdX Trading Inc. All rights reserved.
//

import UIKit
import Utilities

private enum FeedbackType: String {
    case lowImpact
    case mediumImpact
    case highImpact
    case selection
    case success
    case warning
    case error
}

public enum FeedbackKey: String {
    case lowImpact
    case mediumImpact
    case highImpact
    case selection
    case notification
}

public typealias HapticCallback = (_ feedback: UIFeedbackGenerator?) -> Void

@objc public class HapticData: NSObject {
    public var key: FeedbackKey? {
        didSet {
            didSetKey(oldValue: oldValue)
        }
    }

    public var lock: Int = 0 {
        didSet {
            didSetLock(oldValue: oldValue)
        }
    }

    public var feedback: UIFeedbackGenerator?
    public var prepareTime: Date?

    private func didSetKey(oldValue: FeedbackKey?) {
        if key != oldValue {
            generate()
        }
    }

    private func didSetLock(oldValue: Int?) {
        if lock != oldValue {
            generate()
        }
    }

    private func generate() {
        if let key = key {
            if lock != 0 {
                if feedback === nil {
                    switch key {
                    case .lowImpact:
                        feedback = UIImpactFeedbackGenerator(style: .light)

                    case .mediumImpact:
                        feedback = UIImpactFeedbackGenerator(style: .medium)

                    case .highImpact:
                        feedback = UIImpactFeedbackGenerator(style: .heavy)

                    case .selection:
                        feedback = UISelectionFeedbackGenerator()

                    case .notification:
                        feedback = UINotificationFeedbackGenerator()
                    }
                }
            } else {
                feedback = nil
            }
        }
    }

    public func prepare(callback: HapticCallback?) {
        let now = Date()
        if let previousPrepare = prepareTime {
            let elapsed = now.timeIntervalSince(previousPrepare)
            if elapsed > 1 {
                feedback?.prepare()
            }
        } else {
            feedback?.prepare()
        }
        prepareTime = Date()
        callback?(feedback)
    }
}

@objc public class MotionHapticFeedback: NSObject, HapticFeedbackProtocol {
//    private var cache: [FeedbackKey: UIFeedbackGenerator] = [:]
//    private var lockCache: [FeedbackKey: Int] = [:]

    private var cache: [FeedbackKey: HapticData] = [:]

    public func prepareImpact(level: ImpactLevel) {
        switch level {
        case .low:
            prepare(type: .lowImpact)
        case .medium:
            prepare(type: .mediumImpact)
        case .high:
            prepare(type: .highImpact)
        }
    }

    public func prepareSelection() {
        prepare(type: .selection)
    }

    public func prepareNotify(type: NotificationType) {
        switch type {
        case .success:
            prepare(type: .success)
        case .warnng:
            prepare(type: .warning)
        case .error:
            prepare(type: .error)
        }
    }

    public func impact(level: ImpactLevel) {
        switch level {
        case .low:
            trigger(type: .lowImpact)
        case .medium:
            trigger(type: .mediumImpact)
        case .high:
            trigger(type: .highImpact)
        }
    }

    public func selection() {
        trigger(type: .selection)
    }

    public func notify(type: NotificationType) {
        switch type {
        case .success:
            trigger(type: .success)
        case .warnng:
            trigger(type: .warning)
        case .error:
            trigger(type: .error)
        }
    }

    private func prepare(type: FeedbackType) {
        lock(key: key(type: type), callback: nil)
    }

    private func trigger(type: FeedbackType) {
        lock(key: key(type: type), callback: { [weak self] feedback in
            self?.trigger(feedback: feedback, type: type)
        })
    }

    private func key(type: FeedbackType) -> FeedbackKey {
        switch type {
        case .lowImpact:
            return .lowImpact
        case .mediumImpact:
            return .mediumImpact
        case .highImpact:
            return .highImpact
        case .selection:
            return .selection
        case .success:
            fallthrough
        case .warning:
            fallthrough
        case .error:
            return .notification
        }
    }

    private func trigger(feedback: UIFeedbackGenerator?, type: FeedbackType) {
        if let feedback = feedback {
            switch type {
            case .lowImpact:
                fallthrough
            case .mediumImpact:
                fallthrough
            case .highImpact:
                (feedback as? UIImpactFeedbackGenerator)?.impactOccurred()

            case .selection:
                (feedback as? UISelectionFeedbackGenerator)?.selectionChanged()

            case .success:
                (feedback as? UINotificationFeedbackGenerator)?.notificationOccurred(.success)

            case .warning:
                (feedback as? UINotificationFeedbackGenerator)?.notificationOccurred(.warning)

            case .error:
                (feedback as? UINotificationFeedbackGenerator)?.notificationOccurred(.error)
            }
        } else {
        }
    }

    private func lock(key: FeedbackKey, callback: HapticCallback?) {
        incrementLock(key: key, callback: callback)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.decrementLock(key: key)
        }
    }

    private func incrementLock(key: FeedbackKey, callback: HapticCallback?) {
        var data = cache[key]
        if data === nil {
            data = HapticData()
            data?.key = key
            cache[key] = data
        }
        data?.lock = (data?.lock ?? 0) + 1
        data?.prepare(callback: callback)
    }

    private func decrementLock(key: FeedbackKey) {
        if let data = cache[key] {
            data.lock = data.lock - 1
        }
    }
}
