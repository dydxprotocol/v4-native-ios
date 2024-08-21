//
//  TimeCounter.swift
//  Utilities
//
//  Created by Qiang Huang on 5/27/19.
//  Copyright © 2019 dYdX. All rights reserved.
//

import Foundation
import Combine

open class TimeCounter: NSObject, TimeCounterProtocol, CombineObserving {
    public var cancellableMap = [AnyKeyPath : AnyCancellable]()
    
    private var appState: AppState? {
        didSet {
            changeObservation(from: oldValue, to: appState, keyPath: #keyPath(AppState.background)) {[weak self] observer, obj, change, animated in
                self?.background = self?.appState?.background ?? false
            }
        }
    }
    private var wasOn: Bool = false

    private var background: Bool = false {
        didSet {
            if background != oldValue {
                if background {
                    wasOn = on
                    on = false
                } else {
                    on = wasOn
                }
            }
        }
    }

    @objc open dynamic var on: Bool = false {
        didSet {
            if on != oldValue {
                timer?.invalidate()
                timer = nil
                if on {
                    startTime = Date()
                    let next = TimeInterval(Int(previousTime + 1))
                    timer = Timer.scheduledTimer(withTimeInterval: next - previousTime, repeats: false, block: { [weak self] _ in
                        if let self = self, self.on {
                            self.update()
                            self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { [weak self] _ in
                                if let self = self, self.on {
                                    self.update()
                                }
                            })
                        }
                    })
                } else {
                    if let startTime = startTime {
                        let lapsed = Date().timeIntervalSince(startTime)
                        previousTime += lapsed
                        self.startTime = nil
                        update()
                    }
                }
            }
        }
    }

    @objc open dynamic var time: TimeInterval = 0 {
        didSet {
            timeText = time.shortText
        }
    }

    @objc open dynamic var timeText: String?

    private var previousTime: TimeInterval = 0

    private var startTime: Date?

    private var timer: Timer?

    public override init() {
        super.init()
        DispatchQueue.main.async {[weak self] in
            self?.appState = AppState.shared
        }
    }

    private func update() {
        if let startTime = startTime {
            time = previousTime + Date().timeIntervalSince(startTime)
        } else {
            time = previousTime
        }
    }

    deinit {
        on = false
    }
}
