//
//  LocalAuthenticatorProtocol.swift
//  Utilities
//
//  Created by John Huang on 3/16/22.
//  Copyright © 2022 dYdX Trading Inc. All rights reserved.
//

import Foundation
import Combine

public protocol LocalAuthenticatorProtocol {
    var appState: AppState? { get set }
    var paused: Bool { get set }
    func trigger()
}

public class LocalAuthenticator: NSObject {
    public static var shared: LocalAuthenticatorProtocol? {
        didSet {
            shared?.appState = AppState.shared
        }
    }
}

open class TimedLocalAuthenticator: NSObject, LocalAuthenticatorProtocol, CombineObserving {
    public var cancellableMap = [AnyKeyPath: AnyCancellable]()

    public var paused: Bool = false {
        didSet {
            if paused {
                backgroundTimer = nil
            }
        }
    }

    public var appState: AppState? {
        didSet {
            didSetAppState(oldValue: oldValue)
        }
    }

    private var background: Bool = false {
        didSet {
            didSetBackground(oldValue: oldValue)
        }
    }

    private var backgroundTimer: Timer? {
        didSet {
            didSetBackgroundTimer(oldValue: oldValue)
        }
    }

    private func didSetAppState(oldValue: AppState?) {
        changeObservation(from: oldValue, to: appState, keyPath: #keyPath(AppState.background)) {[weak self] observer, obj, change, animated in
            self?.background = self?.appState?.background ?? false
        }
    }

    private func didSetBackground(oldValue: Bool) {
        if background != oldValue {
            if background {
                if !paused {
                    backgroundTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: false, block: { [weak self] _ in
                        self?.trigger()
                        self?.backgroundTimer = nil
                    })
                }
            } else {
                backgroundTimer = nil
            }
        }
    }

    private func didSetBackgroundTimer(oldValue: Timer?) {
        if backgroundTimer !== oldValue {
            oldValue?.invalidate()
        }
    }

    open func trigger() {
    }
}
